# UUF oUF Patch Notes

This repository vendors `Libraries/oUF`.

## Policy for this audit pass
- Keep vendor code as close to upstream as possible during rebase/sync.
- Avoid broad local rewrites inside vendor files unless required for verified addon breakage.
- Prefer addon-side patch points (`Core/`, `Elements/`) for behavior changes.

## Current pass outcome
- No new direct edits were made to `Libraries/oUF` files in the hardening pass.
- oUF-related behavior hardening was implemented on addon-side integration paths:
  - `Core/Config/TagsDatabase.lua`
  - `Elements/DispelHighlight.lua`
  - `Elements/Range.lua`

## Future sync guidance
- When updating oUF, do vendor-sync first, then apply minimal integration patches in separate commits.
- Document each intentional vendor divergence with reason and affected gameplay/system behavior.
