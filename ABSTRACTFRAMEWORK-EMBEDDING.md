# AbstractFramework Integration Guide

## Current Status: OptionalDeps

Currently, UnhaltedUnitFrames uses AbstractFramework as an **OptionalDeps** dependency.

### What This Means

- ✅ Users who have AbstractFramework installed will use it automatically
- ✅ Users without AbstractFramework can still use UUF with fallback UI
- ✅ No duplicate files on disk
- ✅ Smaller addon size overall
- ✅ Proper credit given in Credits panel

### How to Embed AbstractFramework (Future Option)

If you decide to fully embed AbstractFramework into UnhaltedUnitFrames:

#### Step 1: Create Libraries Directory
```
UnhaltedUnitFrames/
├── Libraries/
│   ├── AbstractFramework/           (Create this directory)
│   │   ├── Init.lua
│   │   ├── AbstractFramework.lua
│   │   ├── System/
│   │   ├── Widgets/
│   │   ├── Utils/
│   │   ├── Units/
│   │   ├── Data/
│   │   ├── Executors/
│   │   ├── Libs/
│   │   ├── Locales/
│   │   ├── Media/
│   │   └── Spells/
│   └── (other libs)
```

#### Step 2: Copy AbstractFramework Files
```bash
# From AbstractFramework directory, recursively copy all files to:
# UnhaltedUnitFrames/Libraries/AbstractFramework/
```

#### Step 3: Update Core/Init.xml
Add before other Core scripts:
```xml
<!-- AbstractFramework (embedded) -->
<Script file="Libraries/AbstractFramework/Init.lua"/>
```

#### Step 4: Update UnhaltedUnitFrames.toc

Remove:
```
## OptionalDeps: AbstractFramework
```

This signals the addon no longer depends on external AbstractFramework.

#### Step 5: Create Init.xml for Libraries

If not already exists, create `Libraries/Init.xml`:
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Script file="AbstractFramework/Init.lua"/>
</Ui>
```

#### Step 6: Update Core/Init.xml

Add before other scripts:
```xml
<Include file="Libraries/Init.xml"/>
```

### Namespace Conflicts

AbstractFramework uses the global namespace. When embedding:
- No local namespacing changes needed
- AbstractFramework will register globally as normal
- Just ensure it loads before other code that depends on it

### Testing After Embedding

1. **With AbstractFramework bundled in WoW AddOns**: Should still work
   - WoW will load the external version first if present
   - Or load embedded version if external not present

2. **With OptionalDeps external version removed**: Verify embedded loads
   ```lua
   /run print(AbstractFramework and "Loaded" or "Not Loaded")
   ```

### Pros of Embedding
- ✅ Single addon distribution
- ✅ No dependency on external addon
- ✅ Guaranteed compatibility
- ✅ Simplified user experience

### Cons of Embedding
- ❌ Larger addon size (~500KB+ additional files)
- ❌ Duplicate files if user has AbstractFramework separately
- ✅ Users can still use external version (WoW loads external first)
- ❌ More complex to maintain AbstractFramework updates

### Recommendation

**Keep OptionalDeps approach** unless:
1. AbstractFramework is inactive/abandoned
2. Critical breaking changes in external version
3. User feedback indicates issues with OptionalDeps
4. Need guaranteed control over framework version

AbstractFramework is well-maintained, so OptionalDeps is safe and recommended.

---

*Last Updated: February 17, 2026*
