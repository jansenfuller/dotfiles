#!/bin/bash
# nvim-death-watch.sh — catch whatever is SIGTERM'ing Neovim.
#
# Usage:  bash ~/.config/nvim/tools/nvim-death-watch.sh
# Run it in a spare tmux pane and leave it running. When any nvim process
# disappears it immediately dumps forensic context to the log below.
#
# This script ONLY observes. It never signals or kills anything.
# Written for macOS's stock bash 3.2 (no associative arrays).

LOG="${HOME}/.local/state/nvim/nvim-death-watch.log"
mkdir -p "$(dirname "$LOG")"

echo "=== watcher started $(date '+%Y-%m-%d %H:%M:%S %Z') ===" | tee -a "$LOG"
echo "Watching for nvim deaths. Ctrl-C to stop. Log: $LOG"

# One line per process: "pid<TAB>ppid<TAB>tty<TAB>command"
# IMPORTANT: match only processes whose *executable* is actually nvim.
# A naive grep for "nvim" also matches every helper whose command line merely
# contains the path ~/.local/share/nvim/... (mason's curl/git/clang/gem builds,
# wakatime-cli, LSP servers), producing a flood of false "deaths".
snapshot() {
  ps -ax -o pid=,ppid=,tty=,command= 2>/dev/null \
    | awk '{
        pid=$1; ppid=$2; tty=$3;
        exe=$4;
        # strip directory part of the executable
        n=split(exe, parts, "/");
        base=parts[n];
        if (base != "nvim") next;
        $1=$2=$3=""; sub(/^ +/,"");
        print pid"\t"ppid"\t"tty"\t"$0;
      }'
}

PREV="$(snapshot)"
echo "Initially watching PIDs: $(echo "$PREV" | awk 'NF{printf "%s ", $1}')"
echo ""

while true; do
  CUR="$(snapshot)"

  # any pid present in PREV but absent from CUR has died
  echo "$PREV" | while IFS=$'\t' read -r pid ppid tty cmd; do
    [ -z "$pid" ] && continue
    if ! echo "$CUR" | awk -v p="$pid" '$1==p{found=1} END{exit !found}'; then
      TS=$(date '+%Y-%m-%d %H:%M:%S %Z')
      {
        echo ""
        echo "########################################################"
        echo "## nvim PID $pid DIED at $TS"
        echo "##   command : $cmd"
        echo "##   tty     : $tty     parent pid: $ppid"
        echo "########################################################"

        echo "--- was the parent still alive? (if not, parent died first) ---"
        ps -p "$ppid" -o pid=,etime=,command= 2>/dev/null || echo "  parent $ppid GONE too"

        echo "--- load / memory at death ---"
        uptime 2>/dev/null
        memory_pressure 2>/dev/null | tail -3
        sysctl vm.swapusage 2>/dev/null

        echo "--- surviving nvim processes ---"
        snapshot

        echo "--- tmux panes ---"
        tmux list-panes -a -F "session=#{session_name} win=#{window_index} pid=#{pane_pid} cmd=#{pane_current_command} dead=#{pane_dead}" 2>/dev/null

        echo "--- processes started within last ~2 min (possible culprit) ---"
        ps -ax -o pid=,etime=,command= 2>/dev/null \
          | awk '$2 ~ /^[0-9]?[0-9]:[0-9][0-9]$/' | head -25

        echo "--- system log mentioning PID $pid (last 60s) ---"
        log show --last 60s --predicate "eventMessage CONTAINS \"$pid\"" --style compact 2>/dev/null \
          | grep -v "log run noninteractively" | tail -20

        echo "--- security / EDR agents active ---"
        ps -ax -o pid=,command= 2>/dev/null \
          | grep -iE "netskope|crowdstrike|sentinel|jamf|falcon|defender|carbonblack" \
          | grep -v grep | head -10

        echo "## end report for PID $pid"
      } >> "$LOG" 2>&1
      echo ">>> nvim $pid died at $TS — report appended to $LOG"
    fi
  done

  PREV="$CUR"
  sleep 1
done
