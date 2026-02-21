# String Details

## Method-call syntax
Strings in WoW have a metatable whose __index points at the global `string`
table. This allows any `string.*` function to be called as a method using `:`.

Example:

```
local s = string.format(input, arg1, arg2)
local s = input:format(arg1, arg2)
```

When calling a method on a string literal, wrap it in parentheses so the parser
sees it as an expression:

```
("%d"):format(value)
```

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
