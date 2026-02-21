# Table Details

## Method-call syntax
Any function that takes a table as its first argument can be assigned to a
method on that table and called with `:`. This is more of a language trick than
a recommended pattern, but it can help you understand how `:` works.

Example:

```
tab = {}

tinsert(tab, 1, value)

tab.insert = tinsert
tab:insert(1, value)
```

## Wipe caveat
`table.wipe` and `wipe` clear all keys in a table, including any methods you
attached in this way.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- https://warcraft.wiki.gg/wiki/API_wipe
