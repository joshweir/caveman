# Fork notes

This fork exists to cut the plugin's always-on context cost. It removes the
cavecrew agents and the skills and commands I never invoke. Nothing else changes,
so caveman mode, its hooks and `/caveman <level>` all work as upstream.

## What the fork changes

- `.claude-plugin/plugin.json` gains `"agents": []`, which stops Claude Code
  auto-loading `agents/`. The agent files stay on disk, unread.
- Deleted: all of `skills/`, and every `commands/caveman-*` file.
- Kept: `commands/caveman.md`, both hooks.

Gone with them: the `/caveman-commit`, `/caveman-review`, `/caveman-stats`,
`/caveman-init`, `/caveman-help` and `/caveman-compress` slash commands. Run
`git checkout upstream/main -- <path>` to get one back.

No skill is needed. `SessionStart` and `UserPromptSubmit` both emit the mode
rules, and the tracker hook reads the raw prompt, so it sees `/caveman ultra`
and writes the level flag on its own. Keep `commands/caveman.md` though:
without a registered command, Claude Code answers `/caveman` with
"Unknown command" and the prompt never reaches the hook.

## Tracking upstream

Do not merge. The deletions collide with every upstream edit to those files.
Replay the strip instead:

```sh
git fetch upstream
git reset --hard upstream/main
./strip.sh
git commit -am "strip unused components"
git push --force-with-lease
```

`strip.sh` keeps a whitelist, so new upstream skills are dropped unless you add
them to `KEEP_SKILLS`. It fails loudly if the layout it expects has moved.

## Using the fork as the plugin

`~/.claude-work/settings.json`:

```json
"extraKnownMarketplaces": {
  "caveman": { "source": { "source": "github", "repo": "joshweir/caveman" } }
}
```

The marketplace name stays `caveman`, so the plugin id stays `caveman@caveman`
and needs no re-enabling. After a push:

```sh
claude plugin marketplace update caveman
claude plugin update caveman@caveman   # bare `caveman` reports "Plugin not found"
claude plugin details caveman          # component inventory and token cost
```
