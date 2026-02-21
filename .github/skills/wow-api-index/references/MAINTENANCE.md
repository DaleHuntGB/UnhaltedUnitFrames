# Maintenance Notes

> **Parent skill:** [wow-api-index](../SKILL.md)

## When Adding a New Skill

1. Create the skill directory: `.github/skills/<skill-name>/SKILL.md`
2. Update the index: change the status from :construction: to :white_check_mark:
   in both [SKILL.md](../SKILL.md) and [DOMAIN-SKILLS.md](DOMAIN-SKILLS.md)
3. Add any new `C_` namespaces to [NAMESPACE-LOOKUP.md](NAMESPACE-LOOKUP.md)
4. Add any new categories to [CATEGORY-LOOKUP.md](CATEGORY-LOOKUP.md)
5. Keep the "Current as of" patch version updated in the main SKILL.md

## When the WoW API Changes (New Patch)

1. Check `https://warcraft.wiki.gg/wiki/Patch_X.Y.Z/API_changes` for
   additions/removals
2. Update affected domain skills
3. Remove any newly deprecated functions
4. Add new API systems to the index and lookup tables
5. Update the patch version at the top of the main SKILL.md
