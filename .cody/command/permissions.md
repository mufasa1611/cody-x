---
description: "Switch permission level for this session. Levels: restricted, standard, full"
---

# Permission Level Switcher

You are running in Cody Pro. The user wants to set a permission level for this session.

## Available Levels

### 1. Restricted (read-only)
- Inspect only — no file edits, no shell commands, no changes
- All mutations must be reported as recommendations only
- Safe for reviewing unfamiliar systems

### 2. Standard (ask before mutations)
- Read-only operations run automatically
- File edits, destructive commands, and system changes ask for approval first
- Default level for the operator agent

### 3. Full (session full permissions)
- All operations run automatically for THIS SESSION only
- No approval prompts for mutations
- Resets to Standard when the session ends or a new session starts
- Use when you trust the current task and want maximum speed

## Instructions

1. If the user provided a level name as argument (e.g. `/permissions full`), apply it immediately.
2. If no argument given, show the 3 levels with descriptions and ask which one.
3. Once chosen, confirm the level and acknowledge it lasts only for this session.
4. Adjust your behavior accordingly — if Full, do not ask for permission on mutations. If Restricted, do not make any changes.

## Current Session

- Session scope: current conversation only
- Full level resets automatically when session ends
