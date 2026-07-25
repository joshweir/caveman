# Fork notes

This fork exists to cut the plugin's always-on context cost. It removes the
cavecrew agents and the skills and commands I never invoke. Nothing else changes,
so caveman mode, its hooks and `/caveman <level>` all work as upstream.

## What the fork changes

- `.claude-plugin/plugin.json` gains `"agents": []`, which stops Claude Code
  auto-loading `agents/`. The agent files stay on disk, unread.
- Deleted: `skills/cavecrew`, `skills/caveman-commit`, `skills/caveman-review`,
  `skills/caveman-stats`, and the matching `commands/caveman-*` files.
- Kept: `skills/caveman`, `skills/caveman-compress`, `skills/caveman-help`,
  `commands/caveman.md`, both hooks.

Gone with them: the `/caveman-commit`, `/caveman-review`, `/caveman-stats` and
`/caveman-init` slash commands. Run `git checkout upstream/main -- <path>` to get
one back.

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
claude plugin update caveman
claude plugin details caveman   # component inventory and token cost
```
