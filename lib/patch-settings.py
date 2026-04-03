#!/usr/bin/env python3
"""Patch Claude Code settings.json for iSparto hook registration.

Usage:
  patch-settings.py patch-user <path> <hook-cmd> <matcher> [matcher ...]
    Register hook command for given matchers in user-level settings.
    Cleans workflow matchers (Edit/Write/Codex) from user level.
    Output: PATCHED | ERROR: <msg> | (nothing if no change needed)

  patch-settings.py clean-project <path>
    Remove Bash matcher's pre-tool-check.sh from project-level settings.
    Output: CLEANED | (nothing if no change needed)
"""

import json
import sys
import os

# Workflow matchers that belong at project level, not user level
WORKFLOW_MATCHERS = ['Edit', 'Write', 'mcp__codex-dev__codex', 'mcp__codex-reviewer__codex']


def load_settings(path):
    """Load settings from JSON file, return {} if missing or invalid."""
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return json.load(f)


def save_settings(path, settings):
    """Write settings to JSON file with trailing newline."""
    with open(path, 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')


def ensure_pre_tool_use(settings):
    """Ensure settings.hooks.PreToolUse exists as a list. Returns (hooks_dict, ptu_list, changed)."""
    changed = False
    hooks = settings.get('hooks')
    if not isinstance(hooks, dict):
        hooks = {}
        settings['hooks'] = hooks
        changed = True
    ptu = hooks.get('PreToolUse')
    if not isinstance(ptu, list):
        ptu = []
        hooks['PreToolUse'] = ptu
        changed = True
    return hooks, ptu, changed


def clean_empty_hooks(settings, hooks):
    """Remove empty PreToolUse/hooks structures."""
    if not hooks.get('PreToolUse'):
        if 'PreToolUse' in hooks:
            del hooks['PreToolUse']
        if not hooks:
            del settings['hooks']


def patch_user(path, hook_cmd, matchers):
    """Register hook for matchers + clean workflow matchers from user level."""
    try:
        settings = load_settings(path)
    except Exception as e:
        print('ERROR: ' + str(e))
        return

    hooks, ptu, changed = ensure_pre_tool_use(settings)

    # Add hook command to each required matcher
    for matcher in matchers:
        matched_entry = None
        for entry in ptu:
            if isinstance(entry, dict) and entry.get('matcher') == matcher:
                matched_entry = entry
                break

        if matched_entry is None:
            ptu.append({
                'matcher': matcher,
                'hooks': [{'type': 'command', 'command': hook_cmd}]
            })
            changed = True
            continue

        entry_hooks = matched_entry.get('hooks')
        if not isinstance(entry_hooks, list):
            entry_hooks = []
            matched_entry['hooks'] = entry_hooks
            changed = True

        has_hook = any(
            isinstance(h, dict) and h.get('command') == hook_cmd
            for h in entry_hooks
        )
        if not has_hook:
            entry_hooks.append({'type': 'command', 'command': hook_cmd})
            changed = True

    # Clean workflow matchers from user level (they belong at project level)
    new_ptu = []
    for entry in ptu:
        if isinstance(entry, dict) and entry.get('matcher') in WORKFLOW_MATCHERS:
            eh = entry.get('hooks', [])
            new_eh = [h for h in eh if not (
                isinstance(h, dict) and h.get('command', '').endswith('pre-tool-check.sh')
            )]
            if len(new_eh) != len(eh):
                changed = True
            if new_eh:
                entry['hooks'] = new_eh
                new_ptu.append(entry)
            else:
                changed = True
        else:
            new_ptu.append(entry)
    hooks['PreToolUse'] = new_ptu

    if not changed:
        return

    clean_empty_hooks(settings, hooks)
    save_settings(path, settings)
    print('PATCHED')


def clean_project(path):
    """Remove Bash matcher's pre-tool-check.sh from project-level settings."""
    try:
        settings = load_settings(path)
    except Exception:
        return

    hooks = settings.get('hooks', {})
    ptu = hooks.get('PreToolUse', [])
    if not isinstance(ptu, list) or not ptu:
        return

    changed = False
    new_ptu = []
    for entry in ptu:
        if not isinstance(entry, dict):
            new_ptu.append(entry)
            continue
        if entry.get('matcher') == 'Bash':
            entry_hooks = entry.get('hooks', [])
            new_eh = [h for h in entry_hooks if not (
                isinstance(h, dict) and h.get('command', '').endswith('pre-tool-check.sh')
            )]
            if len(new_eh) != len(entry_hooks):
                changed = True
            if new_eh:
                entry['hooks'] = new_eh
                new_ptu.append(entry)
            else:
                changed = True
        else:
            new_ptu.append(entry)

    if not changed:
        return

    if new_ptu:
        hooks['PreToolUse'] = new_ptu
    else:
        del hooks['PreToolUse']
        if not hooks:
            del settings['hooks']

    save_settings(path, settings)
    print('CLEANED')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('ERROR: usage: patch-settings.py <patch-user|clean-project> <path> [args...]')
        sys.exit(1)

    command = sys.argv[1]
    if command == 'patch-user':
        if len(sys.argv) < 5:
            print('ERROR: usage: patch-settings.py patch-user <path> <hook-cmd> <matcher> [...]')
            sys.exit(1)
        patch_user(sys.argv[2], sys.argv[3], sys.argv[4:])
    elif command == 'clean-project':
        clean_project(sys.argv[2])
    else:
        print('ERROR: unknown command: ' + command)
        sys.exit(1)
