# UnhaltedUnitFrames Audit Findings (2026-02-22)

## Baseline
- Audit branch: `audit/uuf-hardening-rebase-20260222`
- Base sync target: `upstream/master` (`c6063c13c5c3ee0184e864224e6e1471690ac456`)
- Current branch head after rebase: `db25f28e77e407216d78ac1654084c854dca4b1b`
- wow-ui-source live reference: `d75e26bba581f03525a317c924c4bddbda167798`

## Compatibility Findings Matrix

| File | Issue | Risk | Fix Applied | Proof/Source |
|---|---|---|---|---|
| `Core/Config/TagsDatabase.lua` | Tag formatters used raw `UnitHealth`/`UnitPower`/`UnitName` values in `string.format`, which can be secret/non-displayable in modern Retail combat contexts. | High | Added centralized safe coercion path (`SafeValue`/`SafeNumber`/`SafeString` via `UUF.Utilities`) and rewired health/power/name tag methods to avoid formatting secret values. | WoW API skill refs: `wow-api-combat` (secret values), `wow-api-events` (event-driven update constraints). |
| `Core/PerformanceProfiler.lua` | Bottleneck output emitted one `frame_spike` entry per sample >33ms, causing noisy/truncated reports. | Medium | Replaced per-spike flood with `frame_spike_summary` + top-3 sample spikes; added safer percentile indexing and FPS guard in sampler. | Local profiler output evidence and code-path analysis in profiler module. |
| `Elements/Range.lua` | Active spell cache updated on limited events, risking stale range spell lists after talent/spec updates. | Medium | Added `TRAIT_CONFIG_UPDATED`, `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_TALENT_UPDATE` to spell cache refresh events. | WoW event refs from `wow-api-events` and practical class/spec update behavior. |
| `Elements/DispelHighlight.lua` | Spellbook/talent event list duplicated and susceptible to drift between modules. | Medium | Routed spellbook/talent registration through shared compatibility alias (`UUF_SPELLBOOK_STATE_CHANGED`) when `UUF.Utilities` is available. | Internal compatibility map in `Core/Utilities.lua`; event refs from `wow-api-events`. |
| `Core/Utilities.lua` | No centralized event compatibility aliasing for spellbook/talent state transitions. | Low | Added `Utilities.EventCompatibility`, `ResolveEventList`, and `RegisterCompatibilityEvents`. | Addon hardening policy + event reference docs. |

## Static Scan Results
- Legacy combat log addon APIs not present in in-scope code (`Core/`, `Elements/`, `Libraries/oUF/`) for this branch state.
- No unresolved merge conflict markers in in-scope source.
- Secret-value-sensitive tag formatting paths hardened in custom tag methods.

## Deferred / Known Risks
- `Libraries/oUF` still contains legacy-style events (`PLAYER_TALENT_UPDATE`) in upstream/vendor code paths. This pass keeps vendor code stable and documents divergence policy rather than broad rewriting.
- In-game smoke matrix (combat/arena/raid/edit mode/profile ops) must be validated inside WoW client; not executable from this shell.
