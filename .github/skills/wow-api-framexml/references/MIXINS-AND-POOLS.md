# Mixins & Object Pools

> **Parent skill:** [wow-api-framexml](../SKILL.md)
> **Source:** [FrameXML functions — Mixins](https://warcraft.wiki.gg/wiki/FrameXML_functions#Mixins)
> **Complete mixin list:** [BlizzardInterfaceResources/Mixins.lua](https://github.com/Ketho/BlizzardInterfaceResources/blob/mainline/Resources/Mixins.lua)

[Mixins](https://en.wikipedia.org/wiki/Mixin) are similar to classes in OOP languages. An object can "inherit" from multiple mixins by copying their fields/methods into itself.

---

## Core Mixin Functions

### `Mixin(object, ...)`
Source: [Mixin (FrameXML)](https://www.townlong-yak.com/framexml/go/Mixin)

Copies one or more mixin tables into an **existing** object. Fields/methods from the mixins are merged onto the target object.

**Syntax:**
```lua
Mixin(object, mixin1 [, mixin2, ...])
```

**Arguments:**
- `object` (table) — The target object to receive mixin members.
- `...` (tables) — One or more mixin tables whose fields are copied onto `object`.

**Returns:**
- `object` (table) — The same object, now augmented with mixin members.

**Example:**
```lua
local MyMixin = {}
function MyMixin:Init() self.ready = true end

local obj = {}
Mixin(obj, MyMixin)
obj:Init()  -- obj.ready is now true
```

---

### `CreateFromMixins(...)`
Source: [CreateFromMixins (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateFromMixins)

Creates a **new** table and copies one or more mixin tables into it. Equivalent to `Mixin({}, ...)`.

**Syntax:**
```lua
obj = CreateFromMixins(mixin1 [, mixin2, ...])
```

**Returns:**
- `obj` (table) — A new table with all mixin members copied in.

---

## Mixin Constructors

### `CreateColor(r, g, b, a)`
Source: [CreateColor (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateColor)
Detailed Reference: [ColorMixin](https://warcraft.wiki.gg/wiki/ColorMixin)

Returns a **ColorMixin** object with `.r`, `.g`, `.b`, `.a` fields and color utility methods.

**Syntax:**
```lua
color = CreateColor(r, g, b [, a])
```

**Arguments:**
- `r` (number) — Red component (0–1).
- `g` (number) — Green component (0–1).
- `b` (number) — Blue component (0–1).
- `a` (number) — Optional alpha component (0–1, default 1).

---

### `CreateRectangle(left, right, top, bottom)`
Source: [CreateRectangle (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateRectangle)

Returns a **RectangleMixin** object.

**Syntax:**
```lua
rect = CreateRectangle(left, right, top, bottom)
```

---

### `CreateVector2D(x, y)`
Source: [CreateVector2D (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateVector2D)
Detailed Reference: [Vector2DMixin](https://warcraft.wiki.gg/wiki/Vector2DMixin)

Returns a **Vector2DMixin** object with `.x` and `.y` fields and vector math methods.

**Syntax:**
```lua
vec = CreateVector2D(x, y)
```

---

### `CreateVector3D(x, y, z)`
Source: [CreateVector3D (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateVector3D)
Detailed Reference: [Vector3DMixin](https://warcraft.wiki.gg/wiki/Vector3DMixin)

Returns a **Vector3DMixin** object with `.x`, `.y`, `.z` fields.

**Syntax:**
```lua
vec = CreateVector3D(x, y, z)
```

---

### `SpellMixin:CreateFromSpellID(spellID)`
Source: [SpellMixin (FrameXML 9.0.2)](https://www.townlong-yak.com/framexml/9.0.2/ObjectAPI/Spell.lua#4)
Detailed Reference: [SpellMixin](https://warcraft.wiki.gg/wiki/SpellMixin)

Returns a **SpellMixin** object associated with the given spell ID. Provides async-safe methods for querying spell data.

**Syntax:**
```lua
spell = SpellMixin:CreateFromSpellID(spellID)
```

---

### `Item:CreateFromItemID(itemID)`
Source: [ItemMixin (FrameXML 9.0.2)](https://www.townlong-yak.com/framexml/9.0.2/ObjectAPI/Item.lua#40)
Detailed Reference: [ItemMixin](https://warcraft.wiki.gg/wiki/ItemMixin)

Returns an **ItemMixin** object associated with the given item ID.

**Syntax:**
```lua
item = Item:CreateFromItemID(itemID)
```

---

### `ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)`
Source: [ItemLocationMixin (FrameXML 9.0.2)](https://www.townlong-yak.com/framexml/9.0.2/ObjectAPI/ItemLocation.lua#9)
Detailed Reference: [ItemLocationMixin](https://warcraft.wiki.gg/wiki/ItemLocationMixin)

Returns an **ItemLocationMixin** object representing a specific bag slot.

**Syntax:**
```lua
itemLoc = ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
```

---

### `PlayerLocation:CreateFromGUID(guid)`
Source: [PlayerLocationMixin (FrameXML 9.0.2)](https://www.townlong-yak.com/framexml/9.0.2/ObjectAPI/PlayerLocation.lua#4)
Detailed Reference: [PlayerLocationMixin](https://warcraft.wiki.gg/wiki/PlayerLocationMixin)

Returns a **PlayerLocationMixin** object for a player identified by GUID.

**Syntax:**
```lua
playerLoc = PlayerLocation:CreateFromGUID(guid)
```

---

### `TransmogUtil.CreateTransmogLocation(slotDescriptor, transmogType, modification)`
Source: [TransmogUtil (FrameXML 9.0.2)](https://www.townlong-yak.com/framexml/9.0.2/TransmogUtil.lua#76)
Detailed Reference: [TransmogLocationMixin](https://warcraft.wiki.gg/wiki/TransmogLocationMixin)

Returns a **TransmogLocationMixin** object.

**Syntax:**
```lua
transmogLoc = TransmogUtil.CreateTransmogLocation(slotDescriptor, transmogType, modification)
```

---

## Notable Mixins (Reusable Patterns)

These are commonly used mixin tables available globally in FrameXML:

| Mixin | Source | Description |
|-------|--------|-------------|
| `CallbackRegistryMixin` | [Wiki](https://warcraft.wiki.gg/wiki/CallbackRegistryMixin) | Event/callback registration system |
| `AnchorMixin` | [Source](https://www.townlong-yak.com/framexml/go/AnchorMixin) | Anchor point abstraction |
| `AnimatedNumericFontStringMixin` | [Source](https://www.townlong-yak.com/framexml/go/AnimatedNumericFontStringMixin) | Animated number display |
| `DoublyLinkedListMixin` | [Source](https://www.townlong-yak.com/framexml/go/DoublyLinkedListMixin) | Doubly-linked list data structure |
| `GridLayoutMixin` | [Source](https://www.townlong-yak.com/framexml/go/GridLayoutMixin) | Grid-based layout helper |
| `LineMixin` | [Source](https://www.townlong-yak.com/framexml/go/LineMixin) | Line drawing abstraction |
| `MapCanvasMixin` | [Source](https://www.townlong-yak.com/framexml/go/MapCanvasMixin) | Map canvas rendering |
| `SecondsFormatterMixin` | [Source](https://www.townlong-yak.com/framexml/go/SecondsFormatterMixin) | Configurable time formatting |
| `SparseGridMixin` | [Source](https://www.townlong-yak.com/framexml/go/SparseGridMixin) | Sparse grid data structure |
| `TextureLoadingGroupMixin` | [Source](https://www.townlong-yak.com/framexml/go/TextureLoadingGroupMixin) | Grouped texture loading |

---

## Object & Frame Pools

Object pools allow efficient reuse of frames and other UI objects without constantly creating/destroying them.

### `CreateObjectPool(creationFunc, resetterFunc)`
Detailed Reference: [API CreateObjectPool](https://warcraft.wiki.gg/wiki/API_CreateObjectPool)
See also: [ObjectPoolMixin](https://warcraft.wiki.gg/wiki/ObjectPoolMixin)

Creates an **ObjectPoolMixin** for reusing any type of [widget](https://warcraft.wiki.gg/wiki/UIOBJECT_UIObject).

**Syntax:**
```lua
pool = CreateObjectPool(creationFunc, resetterFunc)
```

**Arguments:**
- `creationFunc` (function) — Called to create a new object when the pool is empty. Receives the pool as argument.
- `resetterFunc` (function) — Called when an object is returned to the pool. Receives the pool and object.

---

### `CreateFramePool(frameType [, parent, frameTemplate, resetterFunc, forbidden])`
Detailed Reference: [API CreateFramePool](https://warcraft.wiki.gg/wiki/API_CreateFramePool)
See also: [FramePoolMixin](https://warcraft.wiki.gg/wiki/FramePoolMixin)

Creates a **FramePoolMixin** specifically for reusing [Frames](https://warcraft.wiki.gg/wiki/UIOBJECT_Frame).

**Syntax:**
```lua
pool = CreateFramePool(frameType [, parent, frameTemplate, resetterFunc, forbidden])
```

**Arguments:**
- `frameType` (string) — Frame type (e.g., `"Frame"`, `"Button"`, `"StatusBar"`).
- `parent` (Frame) — Parent frame for created frames.
- `frameTemplate` (string) — XML template name.
- `resetterFunc` (function) — Custom reset function.
- `forbidden` (boolean) — If true, creates forbidden (protected) frames.

---

### `CreateTexturePool(parent [, layer, subLayer, textureTemplate, resetterFunc])`
Source: [FrameXML functions](https://warcraft.wiki.gg/wiki/FrameXML_functions#Mixins)

Creates a **TexturePoolMixin** for reusing [Textures](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture).

**Syntax:**
```lua
pool = CreateTexturePool(parent [, layer, subLayer, textureTemplate, resetterFunc])
```

---

### `CreateFontStringPool(parent [, layer, subLayer, fontStringTemplate, resetterFunc])`
Source: [FrameXML functions](https://warcraft.wiki.gg/wiki/FrameXML_functions#Mixins)

Creates a **FontStringPoolMixin** for reusing [FontStrings](https://warcraft.wiki.gg/wiki/UIOBJECT_FontString).

**Syntax:**
```lua
pool = CreateFontStringPool(parent [, layer, subLayer, fontStringTemplate, resetterFunc])
```

---

### `CreateActorPool(parent [, actorTemplate, resetterFunc])`
Source: [FrameXML functions](https://warcraft.wiki.gg/wiki/FrameXML_functions#Mixins)

Creates an **ActorPoolMixin** for reusing Actors.

**Syntax:**
```lua
pool = CreateActorPool(parent [, actorTemplate, resetterFunc])
```

---

### `CreateFramePoolCollection()`
Source: [CreateFramePoolCollection (FrameXML)](https://www.townlong-yak.com/framexml/go/CreateFramePoolCollection)
Detailed Reference: [FramePoolCollectionMixin](https://warcraft.wiki.gg/wiki/FramePoolCollectionMixin)

Creates a **FramePoolCollectionMixin** that manages multiple [frame pools](https://warcraft.wiki.gg/wiki/FramePoolMixin) grouped by type/template.

**Syntax:**
```lua
collection = CreateFramePoolCollection()
```
