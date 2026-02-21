# Bit Library

World of Warcraft includes the Lua bitlib library in the `bit` table. This
library works with 32-bit integer behavior.

## Notes
- The library behaves like 32-bit signed integer math (for example,
`bit.lshift(0x80000000, 1) == 0`).
- Packing data with bit operations is slower than storing values directly in
separate variables or table fields for most addon use cases.

## Function summaries

### `bit.bnot(a)`
Bitwise NOT (ones complement) of `a`.

### `bit.band(a1, ...)`
Bitwise AND of all arguments.

### `bit.bor(a1, ...)`
Bitwise OR of all arguments.

### `bit.bxor(a1, ...)`
Bitwise XOR of all arguments.

### `bit.lshift(a, n)`
Left shift `a` by `n` bits.

### `bit.rshift(a, n)`
Logical right shift `a` by `n` bits.

### `bit.arshift(a, n)`
Arithmetic right shift `a` by `n` bits.

### `bit.mod(a, n)`
Signed modulus of `a` by `n`. The result keeps the sign of `a`.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
