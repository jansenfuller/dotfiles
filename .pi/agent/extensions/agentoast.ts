/**
 * agentoast integration for pi
 * https://github.com/shuntaka9576/agentoast
 *
 * Toast notifications for three events:
 *  • agent_settled   → "Stop"             (green)  pi finished a task
 *  • permissions:ui_prompt → "permission_prompt" (blue) pi needs permission
 *  • ask_user_question     → "idle_prompt"        (blue) pi is asking a question
 *
 * Requires: agentoast (brew install --cask shuntaka9576/tap/agentoast)
 * Config:   ~/.config/agentoast/config.toml  (claude_code section applies)
 *
 * Notes:
 *  - "permission_prompt" fires by default (it's in the default events list).
 *  - "idle_prompt" (questions) is excluded by default; add it to your config:
 *      [notification.agents.claude_code]
 *      events = ["Stop", "permission_prompt", "auth_success", "elicitation_dialog", "idle_prompt"]
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

// Channel name published by @gotgenes/pi-permission-system
const PERMISSIONS_UI_PROMPT_CHANNEL = "permissions:ui_prompt";

interface PermissionUiPromptEvent {
  requestId: string;
  source: string;
  surface: string | null;
  value: string | null;
  agentName: string | null;
  message: string;
  forwarding: unknown | null;
}

/** Pipe a Claude-compatible hook payload to `agentoast hook claude` on stdin. */
function fireHook(payload: Record<string, unknown>): void {
  try {
    spawnSync("agentoast", ["hook", "claude"], {
      input: JSON.stringify(payload),
      encoding: "utf8",
      env: process.env, // pass TMUX_PANE + __CFBundleIdentifier through
      timeout: 3000,
    });
  } catch {
    // silently ignore — agentoast may not be running or installed
  }
}

/** Extract the last assistant text from the session. */
function getLastAssistantMessage(ctx: ExtensionContext): string {
  try {
    const entries = ctx.sessionManager.getEntries();
    for (let i = entries.length - 1; i >= 0; i--) {
      const entry = entries[i] as Record<string, unknown>;
      const msg = entry.message as Record<string, unknown> | undefined;
      if (msg?.role !== "assistant") continue;
      const content = msg.content;
      if (Array.isArray(content)) {
        const textBlock = (content as Array<Record<string, unknown>>).find(
          (c) => c.type === "text" && typeof c.text === "string",
        );
        if (textBlock) return textBlock.text as string;
      } else if (typeof content === "string" && content) {
        return content;
      }
    }
  } catch {
    // ignore session access errors
  }
  return "";
}

export default function (pi: ExtensionAPI) {
  // Track cwd for events that don't have ctx (pi.events listeners)
  let currentCwd = process.cwd();

  pi.on("session_start", async (_event, ctx) => {
    currentCwd = ctx.cwd;
  });

  // ── Stop ────────────────────────────────────────────────────────────────────
  // agent_settled fires once the agent is truly done — no pending retries,
  // auto-compactions, or queued follow-up messages.
  pi.on("agent_settled", async (_event, ctx) => {
    currentCwd = ctx.cwd;
    fireHook({
      hook_event_name: "Stop",
      cwd: ctx.cwd,
      last_assistant_message: getLastAssistantMessage(ctx),
    });
  });

  // ── Permission prompts ──────────────────────────────────────────────────────
  // The permission-system extension broadcasts on pi.events immediately before
  // it shows the permission dialog. Fire "permission_prompt" so agentoast
  // notifies the user they need to answer a permission request.
  pi.events.on(PERMISSIONS_UI_PROMPT_CHANNEL, (data) => {
    const evt = data as PermissionUiPromptEvent;
    const body =
      evt.message ||
      [evt.surface, evt.value].filter(Boolean).join(" — ") ||
      "Permission needed";

    fireHook({
      hook_event_name: "Notification",
      notification_type: "permission_prompt",
      cwd: currentCwd,
      message: body,
    });
  });

  // ── Questions from LLM ──────────────────────────────────────────────────────
  // When the LLM calls ask_user_question, it needs the user's input.
  // Uses "idle_prompt" type — enable it in ~/.config/agentoast/config.toml to
  // receive these toasts (excluded from the default event list).
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "ask_user_question") return;

    type AskInput = { questions?: Array<{ question?: string }> };
    const input = event.input as AskInput;
    const firstQuestion = input?.questions?.[0]?.question ?? "Question from agent";

    fireHook({
      hook_event_name: "Notification",
      notification_type: "idle_prompt",
      cwd: currentCwd,
      message: firstQuestion,
    });
  });
}
