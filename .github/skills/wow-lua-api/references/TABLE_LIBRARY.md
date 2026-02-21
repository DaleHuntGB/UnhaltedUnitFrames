# Table Library

These helpers come from the Lua table library and are available as `table.*`
functions in the WoW client. Some also have global aliases.

## Notes
- Many table functions assume a list-like table with numeric keys starting at 1
and no holes. Using other shapes can lead to undefined behavior.
- Method-call syntax is documented in TABLE_DETAILS.md.

## Function summaries

### `table.concat(list[, sep[, i[, j]]])`
Concatenates the values in `list` into a single string. Use `sep` as a
separator and `i` and `j` to limit the range.

### `table.create(arraySizeHint[, nodeSizeHint])`
WoW-only helper that preallocates a table with array and hash size hints.

### `table.insert(list[, pos], value)` or `tinsert(list[, pos], value)`
Inserts `value` at position `pos` (or at the end when omitted).

### `table.maxn(list)`
Returns the largest positive numeric index in the list, or 0 if none exist.

### `table.remove(list[, pos])` or `tremove(list[, pos])`
Removes and returns the value at `pos` (or the last value when omitted).

### `table.removemulti(list[, pos[, count]])`
WoW-only helper that removes `count` elements starting at `pos`.

### `table.sort(list[, comp])` or `sort(list[, comp])`
Sorts the list in place, optionally using a custom comparator.

### `table.wipe(list)` or `wipe(list)`
Clears the table in place without creating a new table.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- http://www.lua.org/manual/5.1/manual.html
