# Deprecated Functions

These functions are deprecated or obsolete in the WoW Lua environment. Prefer
the replacements listed here.

## Deprecated

### `table.foreach(table, function)` or `foreach(table, function)`
Executes a function for each element in a table. Deprecated; use `pairs`.

### `table.foreachi(table, function)` or `foreachi(table, function)`
Executes a function for each sequential element in a table. Deprecated; use
`ipairs`.

### `table.getn(table)` or `getn(table)`
Returns the size of a table when treated as a list. Deprecated; use the length
operator `#`.

## Obsolete (errors if called)

### `table.setn(table, n)`
Obsolete; calling it throws an error.

### `string.gfind(s, pattern)`
Obsolete; calling it throws an error. Use `string.gmatch`.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
