/**
 * ctx-enforcer — block native pi tools that have ctx equivalents.
 *
 * Two layers:
 *   1. before_agent_start — rewrites the three base-prompt lines that
 *      contradict ctx-tool usage, in-place, so the system prompt is
 *      self-consistent for every project (no AGENTS.md needed).
 *
 *   2. tool_call intercepts:
 *        read           → ctx_read
 *        edit           → ctx_edit / ctx_patch
 *        grep           → ctx_grep   (native pi tool, not bash grep)
 *        find           → ctx_find   (native pi tool, not bash find)
 *        ls             → ctx_ls     (native pi tool, not bash ls)
 *        bash/ctx_shell → blocked if any line starts with a redirected cmd
 *
 *      MCP tools and all other custom tools are ALWAYS allowed — they
 *      match none of the above and hit the explicit early return below.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// ── Native pi tool blocks ────────────────────────────────────────────────────
// Keyed by exact toolName; covers read/edit/grep/find/ls.
// write is intentionally absent — no ctx alternative for creating new files.
// MCP tools and custom tools are intentionally absent — always allowed.
const NATIVE_BLOCKS: Record<string, string> = {
  read:
    "Use `ctx_read` instead of `read` — cached and auto-compresses large files. " +
    'Pass `mode="full"` for the complete file.',
  edit:
    "Use `ctx_edit` (search-and-replace, TOCTOU-safe) or `ctx_patch` " +
    '(hash-anchored — requires a prior `ctx_read` with `mode="anchored"`) instead of `edit`.',
  grep: "Use `ctx_grep` instead of the native `grep` tool — gitignore-aware, auto-compressed.",
  find: "Use `ctx_find` instead of the native `find` tool — respects .gitignore.",
  ls:   "Use `ctx_ls` instead of the native `ls` tool — compact, summarised listing.",
};

// ── Bash / ctx_shell command blocks ─────────────────────────────────────────
// Keyed by the leading shell token of a command line.
const SHELL_BLOCKS: Record<string, string> = {
  cat:     "Use `ctx_read` instead of `cat` — cached and token-safe.",
  less:    "Use `ctx_read` instead of `less`.",
  more:    "Use `ctx_read` instead of `more`.",
  head:    "Use `ctx_read` with a `limit` parameter instead of `head`.",
  tail:    "Use `ctx_read` with an `offset` (and optionally `limit`) instead of `tail`.",
  ls:      "Use `ctx_ls` instead of `ls` — compact, summarised listing.",
  grep:    "Use `ctx_grep` instead of `grep` — gitignore-aware, auto-compressed.",
  rg:      "Use `ctx_grep` instead of `rg` — gitignore-aware, auto-compressed.",
  ripgrep: "Use `ctx_grep` instead of `ripgrep`.",
  find:    "Use `ctx_find` instead of `find` — respects .gitignore.",
  fd:      "Use `ctx_find` instead of `fd` — respects .gitignore.",
};

function checkLine(line: string): string | null {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith("#")) return null;
  const stripped = trimmed.replace(/^(?:\w+=\S*\s+)+/, "");
  const leadingCmd = stripped.split(/\s/)[0] ?? "";
  return SHELL_BLOCKS[leadingCmd] ?? null;
}

function getShellRedirect(cmd: string): string | null {
  for (const line of cmd.split("\n")) {
    const reason = checkLine(line);
    if (reason) return reason;
  }
  return null;
}

export default function (pi: ExtensionAPI) {
  // ── System-prompt rewrite ─────────────────────────────────────────────────
  pi.on("before_agent_start", async (event) => {
    const prompt = event.systemPrompt
      .replace(
        /- Use `?read`? to examine files[^\n]*/g,
        "- Use `ctx_read` to read files — NOT the native `read` tool (blocked)",
      )
      .replace(
        /- Pi's native edit is preferred[^\n]*/g,
        "- Use `ctx_edit` (search-and-replace) or `ctx_patch` (hash-anchored) for ALL edits — NOT the native `edit` tool (blocked)",
      )
      .replace(
        /- Use bash for file operations[^\n]*/g,
        "- Do NOT use bash for file operations — use `ctx_ls`, `ctx_grep`, `ctx_find` instead (blocked)",
      );
    return { systemPrompt: prompt };
  });

  // ── Tool-call intercepts ──────────────────────────────────────────────────
  pi.on("tool_call", async (event) => {
    // 1. Block native pi tools that have ctx equivalents.
    const nativeReason = NATIVE_BLOCKS[event.toolName];
    if (nativeReason) return { block: true, reason: nativeReason };

    // 2. MCP tools and all other custom tools — always allow.
    if (event.toolName !== "bash" && event.toolName !== "ctx_shell") return;

    // 3. bash / ctx_shell — scan every line for blocked shell commands.
    const cmd = (event.input as { command?: string }).command ?? "";
    const shellReason = getShellRedirect(cmd);
    if (shellReason) return { block: true, reason: shellReason };
  });
}
