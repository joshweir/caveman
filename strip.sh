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
  name=$(basename "$d")
  keep=no
  for k in $KEEP_SKILLS; do [ "$name" = "$k" ] && keep=yes; done
  [ "$keep" = yes ] || git rm -rq "$d"
done

for c in commands/*; do
  case "$(basename "$c")" in caveman.md|caveman.toml) ;; *) git rm -q "$c" ;; esac
done

# Check: agents gone, only whitelisted skills left.
node -e 'const fs=require("fs");const a=JSON.parse(fs.readFileSync(".claude-plugin/plugin.json","utf8")).agents;if(!Array.isArray(a)||a.length)throw new Error("agents not emptied");const left=fs.existsSync("skills")?fs.readdirSync("skills").sort().join(" "):"";if(left!==process.env.KEEP_SKILLS.trim())throw new Error("unexpected skills: "+left);if(!fs.existsSync("commands/caveman.md"))throw new Error("commands/caveman.md missing - /caveman would stop working");console.log("strip ok: agents [] , skills ["+left+"]")'
