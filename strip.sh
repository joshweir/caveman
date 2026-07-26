#!/bin/sh
# Drop plugin components we never invoke, to cut always-on context cost.
# Re-run after every `git reset --hard upstream/main` (see FORK.md).
# Whitelist, not blocklist: new upstream skills are dropped unless listed here.
set -e
cd "$(dirname "$0")"

# Empty: the hooks carry the mode rules, and commands/caveman.md carries
# /caveman <level>. No skill is needed for either.
KEEP_SKILLS=""
export KEEP_SKILLS

# `agents: []` stops the agents/ directory being auto-loaded at all.
node -e 'const fs=require("fs"),f=".claude-plugin/plugin.json",j=JSON.parse(fs.readFileSync(f,"utf8"));j.agents=[];fs.writeFileSync(f,JSON.stringify(j,null,2)+"\n")'

for d in skills/*/; do
  [ -d "$d" ] || continue   # no skills left (already stripped)
  name=$(basename "$d")
  keep=no
  for k in $KEEP_SKILLS; do [ "$name" = "$k" ] && keep=yes; done
  [ "$keep" = yes ] || git rm -rq "$d"
done

for c in commands/*; do
  [ -e "$c" ] || continue
  case "$(basename "$c")" in caveman.md|caveman.toml) ;; *) git rm -q "$c" ;; esac
done

# Hide the surviving command from the model. `/caveman:caveman <level>` still
# works; the model just stops paying for its listing every session.
node -e 'const fs=require("fs"),f="commands/caveman.md";let t=fs.readFileSync(f,"utf8");if(!/^disable-model-invocation:/m.test(t))fs.writeFileSync(f,t.replace(/^---\n/,"---\ndisable-model-invocation: true\n"))'

# Check: agents gone, only whitelisted skills left.
node -e 'const fs=require("fs");const a=JSON.parse(fs.readFileSync(".claude-plugin/plugin.json","utf8")).agents;if(!Array.isArray(a)||a.length)throw new Error("agents not emptied");const left=fs.existsSync("skills")?fs.readdirSync("skills").sort().join(" "):"";if(left!==process.env.KEEP_SKILLS.trim())throw new Error("unexpected skills: "+left);if(!fs.existsSync("commands/caveman.md"))throw new Error("commands/caveman.md missing - /caveman would stop working");if(!/^disable-model-invocation: true$/m.test(fs.readFileSync("commands/caveman.md","utf8")))throw new Error("commands/caveman.md is still model-invocable");console.log("strip ok: agents [] , skills ["+left+"] , command hidden from model")'
