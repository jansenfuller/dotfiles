/**
 * ctx-enforcer — redirect bare read-only shell commands to ctx tools.
 *
 * Blocks any single-line `bash` or `ctx_shell` call that could be replaced
 * by a faster, cached, gitignore-aware ctx tool:
 *
 *   cat / less / more  →  ctx_read  (or `read`)
 *   head / tail        →  ctx_read  with offset/limit
 *   ls                 →  ctx_ls
 *   grep / rg          →  ctx_grep
 *   find / fd          →  ctx_find
 *
 * Complex commands (multi-line scripts, pipelines, redirects, subshells)
 * are let through unchanged — this only catches the simple "I just need
 * to look at a file/directory" patterns.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Maps a leading shell command to its ctx-tool redirect message. */
const REDIRECTS: Record<string, string> = {
  cat: "Use `ctx_read` (or the `read` tool) instead of `cat` — results are cached and truncated safely.",
  less: "Use `ctx_read` instead of `less`.",
  more: "Use `ctx_read` instead of `more`.",
  head: "Use `ctx_read` with a `limit` parameter instead of `head`.",
  tail: "Use `ctx_read` with `offset` (and optionally `limit`) instead of `tail`.",
  ls: "Use `ctx_ls` instead of `ls` — it returns a compact, summarized listing.",
  grep: "Use `ctx_grep` instead of `grep` — gitignore-aware and auto-compresses output.",
  rg: "Use `ctx_grep` instead of `rg` — gitignore-aware and auto-compresses output.",
  ripgrep: "Use `ctx_grep` instead of `ripgrep`.",
  find: "Use `ctx_find` instead of `find` — respects .gitignore.",
  fd: "Use `ctx_find` instead of `fd` — respects .gitignore.",
};

/**
 * Returns a redirect message if the command is a simple read-only operation
 * that should use a ctx tool, or null to let it through.
 *
 * "Simple" means: single line, no pipes, no redirects, no subshells,
 * no compound operators (;  &&  ||).  Complex commands are always allowed.
 */
function getRedirectReason(cmd: string): string | null {
  // Multi-line scripts are always complex — let them through
  if (cmd.includes("\n")) return null;

  // Pipelines, redirections, subshells, compound operators — let through
  if (/[|><;`]|\$\(|&&|\|\|/.test(cmd)) return null;

  // Strip leading env-var assignments: VAR=val VAR2=val2 cmd args
  const stripped = cmd.trim().replace(/^(?:\w+=\S*\s+)+/, "");

  // Extract the bare command name (before any flags/args)
  const leadingCmd = stripped.split(/\s/)[0] ?? "";

  return REDIRECTS[leadingCmd] ?? null;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash" && event.toolName !== "ctx_shell") return;

    const cmd = (event.input as { command?: string }).command ?? "";
    const reason = getRedirectReason(cmd);
    if (reason) {
      return { block: true, reason };
    }
  });
}
