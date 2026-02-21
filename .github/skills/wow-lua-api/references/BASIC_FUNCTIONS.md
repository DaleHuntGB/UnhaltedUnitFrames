# Basic Functions

These are the core Lua 5.1 base functions available in the WoW client. They are
global functions (not in a library table). Use the Lua 5.1 manual for deeper
behavior details.

## Function summaries

### `assert(value[, errormsg])`
Checks that `value` is truthy. If it is, the value is returned. If not, a Lua
error is raised, optionally using `errormsg`.

### `collectgarbage()`
Forces a garbage collection cycle.

### `date(format, time)`
Returns a formatted date string based on the user's local machine time. Pass
`time` (seconds since epoch) to format a specific timestamp.

### `difftime(t1, t2)`
Returns the number of seconds between two time values.

### `error(message[, level])`
Raises a Lua error with the given message. Use `level` to adjust the reported
stack level.

### `gcinfo()`
Returns addon memory usage and the current GC threshold in kilobytes. This
function is deprecated; use `collectgarbage("count")` instead.

### `getfenv(functionOrLevel)`
Returns the environment table for a function or a stack level.

### `getmetatable(object)`
Returns the metatable of a table or userdata, if one is set.

### `ipairs(table)`
Returns an iterator that walks sequential numeric keys starting at 1 and stops
at the first nil.

### `loadstring(code)`
Parses a string of Lua code and returns it as a callable function value, or an
error if compilation fails.

### `next(table[, index])`
Returns the next key and value in a table. Pass nil for `index` to start.

### `newproxy([booleanOrProxy])`
Creates a userdata with a shareable metatable. Passing true creates a new
metatable; passing an existing proxy reuses its metatable.

### `pairs(table)`
Returns an iterator that walks all key/value pairs in a table.

### `pcall(func[, ...])`
Calls `func` in protected mode. Returns a boolean for success and then either
results or an error message.

### `select(index, list)`
Returns the number of items in a list or a subset of the list starting at
`index`.

### `setfenv(functionOrLevel, table)`
Sets the environment table for a function or a stack level.

### `setmetatable(table, metatable)`
Sets a metatable on a table and returns the table.

### `time([table])`
Returns seconds since the epoch. When a date table is provided, it returns the
timestamp for that date.

### `type(value)`
Returns the type of a value as a string: "nil", "boolean", "number", "string",
"table", "function", "thread", or "userdata".

### `unpack(list[, start[, end]])`
Returns the values in a list as multiple return values.

### `xpcall(func, err[, ...])`
Like `pcall`, but uses the `err` function as an error handler when an error
occurs.

### `rawequal(v1, v2)`
Compares two values for equality without invoking metamethods.

### `rawget(table, index)`
Reads a table entry without invoking metamethods.

### `rawset(table, index, value)`
Writes a table entry without invoking metamethods.

### `tonumber(value[, base])`
Converts a value to a number if possible. When `base` is provided, it is used to
interpret the string; bases other than 10 only accept unsigned integers.

### `tostring(value)`
Converts a value to a string.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- http://www.lua.org/manual/5.1/manual.html
