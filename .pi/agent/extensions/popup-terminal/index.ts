/**
 * Popup Terminal — spawns a shell that persists for the session.
 *
 * Commands:
 *   /terminal            — toggle the popup terminal
 *   /terminal restart    — kill and restart the shell
 *
 * Inside the popup:
 *   All keys → forwarded to the shell
 *   Page Up / Down → scroll viewport
 *   Home / End → scroll to top / bottom
 *   Ctrl+Q → close popup (shell keeps running)
 *
 * Lightweight: spawns shell directly, local echo for input visibility.
 * No external npm deps.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, Key } from "@earendil-works/pi-tui";
import { spawn, type ChildProcess } from "node:child_process";

// ─── Module-level persistent state ──────────────────────────────────────────

const MAX_LINES = 2000;
const lines: string[] = [];
let scrollBack = 0;
let prevVpLines = 15;
let inputLine = "";
let triggerRender: (() => void) | null = null;

// ─── Shell process ──────────────────────────────────────────────────────────

let proc: ChildProcess | null = null;

function spawnShell(): void {
	if (proc && proc.exitCode === null && !proc.killed) return;

	const shell = process.env.SHELL || "/bin/sh";

	proc = spawn(shell, ["-i"], {
		stdio: ["pipe", "pipe", "pipe"],
		env: { ...process.env, TERM: "dumb", PS1: "", PROMPT_COMMAND: "" },
	});

	proc.stdout?.on("data", (chunk: Buffer) => {
		onData(chunk.toString());
		triggerRender?.();
	});
	proc.stderr?.on("data", (chunk: Buffer) => {
		onData(chunk.toString());
		triggerRender?.();
	});
	proc.on("exit", (code) => {
		onData(`\n[exited ${code ?? "?"}]\n`);
		triggerRender?.();
		proc = null;
	});
	proc.on("error", () => {
		proc = null;
		onData("\n[spawn failed]\n");
		triggerRender?.();
	});
}

function killShell(): void {
	const old = proc;
	proc = null;
	if (old && !old.killed) {
		try { old.kill("SIGTERM"); }
		catch { /* ignore */ }
	}
}

function writeSh(data: string): void {
	proc?.stdin?.write(data);
}

function shellAlive(): boolean {
	return proc !== null && proc.exitCode === null && !proc.killed;
}

// ─── Accumulate shell output ────────────────────────────────────────────────

function onData(s: string): void {
	for (const ch of s) {
		if (ch === "\n") {
			lines.push("");
			trim();
		} else if (ch === "\r") {
			// ignore lone CR (CRLF is handled by \n above)
		} else if (ch === "\b" || ch === "\x7f") {
			const cur = lines[lines.length - 1];
			if (cur && cur.length > 0) lines[lines.length - 1] = cur.slice(0, -1);
		} else if (ch >= " ") {
			if (lines.length === 0) lines.push("");
			lines[lines.length - 1] += ch;
		}
	}
}

function trim(): void {
	if (lines.length > MAX_LINES) {
		const remove = lines.length - MAX_LINES;
		lines.splice(0, remove);
	}
}

// ─── Local echo helpers ─────────────────────────────────────────────────────

function echoChar(ch: string): void {
	inputLine += ch;
	triggerRender?.();
}

function echoNewline(): void {
	// Commit the input line to the buffer and send to shell
	lines.push(`$ ${inputLine}`);
	inputLine = "";
	writeSh("\n");
	triggerRender?.();
}

function echoBackspace(): void {
	if (inputLine.length > 0) {
		inputLine = inputLine.slice(0, -1);
		triggerRender?.();
	}
}

function echoCtrlC(): void {
	lines.push(`$ ${inputLine}^C`);
	inputLine = "";
	writeSh("\x03");
	triggerRender?.();
}

function echoCtrlD(): void {
	// Send EOF
	writeSh("\x04");
	triggerRender?.();
}

// ─── Viewport ───────────────────────────────────────────────────────────────

function getViewport(h: number): string[] {
	const total = lines.length;
	if (total === 0) return [];
	const maxSb = Math.max(0, total);
	if (scrollBack > maxSb) scrollBack = maxSb;
	const end = total - scrollBack;
	const start = Math.max(0, end - h);
	return lines.slice(start, end);
}

// ─── Overlay Component (returned as plain object) ───────────────────────────

function createOverlay(tui: any, theme: any, done: () => void) {
	scrollBack = 0;
	let closed = false;

	triggerRender = () => { if (!closed) try { tui.requestRender(); } catch {} };

	const close = () => {
		if (closed) return;
		closed = true;
		clearInterval(exitCheck);
		triggerRender = null;
		done();
	};

	// Auto‑close when shell exits
	const exitCheck = setInterval(() => {
		if (!shellAlive()) {
			clearInterval(exitCheck);
			triggerRender = null;
			setTimeout(() => close(), 1500);
		}
	}, 500);

	triggerRender(); // first paint

	return {
		handleInput(data: string): void {
			// ── Viewport scrolling ──
			if (matchesKey(data, Key.pageUp)) {
				scrollBack = Math.min(scrollBack + prevVpLines, Math.max(0, lines.length));
				tui.requestRender(); return;
			}
			if (matchesKey(data, Key.pageDown)) {
				scrollBack = Math.max(0, scrollBack - prevVpLines);
				tui.requestRender(); return;
			}
			if (matchesKey(data, Key.home)) {
				scrollBack = Math.max(0, lines.length);
				tui.requestRender(); return;
			}
			if (matchesKey(data, Key.end)) {
				scrollBack = 0;
				tui.requestRender(); return;
			}

			// ── Close ──
			if (matchesKey(data, Key.ctrl("q"))) { close(); return; }

			// ── Special keys (local echo + forward) ──
			if (matchesKey(data, "return") || matchesKey(data, "enter")) {
				echoNewline(); return;
			}
			if (matchesKey(data, "backspace")) {
				echoBackspace(); writeSh("\b"); return;
			}
			if (matchesKey(data, Key.ctrl("c"))) {
				echoCtrlC(); return;
			}
			if (matchesKey(data, Key.ctrl("d"))) {
				echoCtrlD(); return;
			}

			// ── Tab ──
			if (matchesKey(data, "tab")) {
				echoChar("\t"); writeSh("\t"); return;
			}

			// ── Arrow keys etc — forward raw, no local echo ──
			if (data.length === 1 && data >= " ") {
				echoChar(data);
				writeSh(data);
				return;
			}

			// Everything else (arrow escape sequences, etc.) — forward raw
			writeSh(data);
		},

		render(width: number): string[] {
			const inner = Math.max(8, width - 2);
			prevVpLines = Math.min(20, Math.max(4, Math.floor(width / 4)));
			const th = theme;
			const mk = (c: string, s: string) => {
				try { return th.fg(c, s); } catch { return s; }
			};

			const out: string[] = [];

			// ── Top border ──
			const icon = shellAlive() ? "●" : "○";
			const title = ` ${icon} Terminal `;
			const avail = Math.max(0, inner - title.length);
			const l = Math.floor(avail / 2), r = avail - l;
			out.push(
				mk("borderAccent", "╭") + mk("dim", "─".repeat(l)) +
				title + mk("dim", "─".repeat(r)) + mk("borderAccent", "╮"),
			);

			// ── Shell output lines ──
			const vp = getViewport(prevVpLines - 1); // leave one row for input line
			for (const line of vp) {
				const d = line.length > inner ? line.slice(0, inner) : line + " ".repeat(inner - line.length);
				out.push(mk("border", "│") + " " + d + " " + mk("border", "│"));
			}

			// ── Input line with prompt ──
			const prompt = mk("success", "$ ");
			const input = shellAlive() ? prompt + inputLine : mk("dim", "(shell not running)");
			const d = input.length > inner ? input.slice(0, inner) : input + " ".repeat(inner - input.length);
			out.push(mk("border", "│") + " " + d + " " + mk("border", "│"));

			// Fill remaining rows if viewport is shorter than available height
			const used = vp.length + 1;
			for (let i = used; i < prevVpLines; i++) {
				out.push(mk("border", "│") + " ".repeat(inner) + mk("border", "│"));
			}

			// ── Status ──
			let status = "Ctrl+Q close";
			if (scrollBack > 0) status += `  ↑${scrollBack}`;
			const sb = status.length > inner ? status.slice(0, inner) : status + " ".repeat(inner - status.length);
			out.push(mk("border", "│") + " " + mk("dim", sb) + " " + mk("border", "│"));

			// ── Bottom border ──
			out.push(mk("borderAccent", "╰") + mk("dim", "─".repeat(inner)) + mk("borderAccent", "╯"));

			return out;
		},

		invalidate(): void {},
	};
}

// ─── Extension Entry ────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.registerCommand("terminal", {
		description: "Toggle popup terminal. 'restart' kills & restarts.",
		handler: async (args: string, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("Terminal requires interactive mode", "error");
				return;
			}

			const cmd = args?.trim().toLowerCase();
			if (cmd === "restart" || cmd === "kill") {
				killShell();
				lines.length = 0;
				inputLine = "";
				scrollBack = 0;
				if (cmd === "restart") {
					spawnShell();
					ctx.ui.notify("Shell restarted", "info");
				} else {
					ctx.ui.notify("Shell killed", "info");
					return;
				}
			}

			if (!shellAlive()) spawnShell();

			await ctx.ui.custom<void>(
				(tui, theme, _kb, done) => createOverlay(tui, theme, done),
				{ overlay: true },
			);
		},
	});

	pi.on("session_shutdown", () => killShell());
}
