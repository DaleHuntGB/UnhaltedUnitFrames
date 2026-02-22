# WoW API Compatibility Notes (Retail 12.x)

## Reference Pin
- wow-ui-source live commit used for alignment: `d75e26bba581f03525a317c924c4bddbda167798`.

## Audit Rules Applied
- Avoid addon use of removed combat log parsing APIs in Retail 12.x.
- Guard string/number formatting against secret values in tag rendering.
- Prefer additive compatibility aliases for event families likely to drift across patches.

## Internal Compatibility Additions
- `Core/Utilities.lua`
  - `Utilities.EventCompatibility`
  - `Utilities.ResolveEventList(...)`
  - `Utilities.RegisterCompatibilityEvents(frame, ...)`

Current alias map:
- `UUF_SPELLBOOK_STATE_CHANGED`
  - `SPELLS_CHANGED`
  - `TRAIT_CONFIG_UPDATED`
  - `PLAYER_SPECIALIZATION_CHANGED`
  - `PLAYER_TALENT_UPDATE`
  - `LEARNED_SPELL_IN_TAB`
  - `LEARNED_SPELL_IN_SKILL_LINE`

## Notes
- Alias map intentionally includes older events to keep low-cost compatibility shims where harmless.
- Primary compatibility target remains Retail 12.x behavior.
