# Coroutine Library

Coroutine helpers are available in WoW, but they should be used sparingly due
to their memory cost.

## Function summaries

### `coroutine.create(f)`
Creates a new coroutine that will run function `f` when resumed.

### `coroutine.resume(co[, val1[, ...]])`
Resumes a suspended coroutine, passing values to it.

### `coroutine.running()`
Returns the currently running coroutine, if any.

### `coroutine.status(co)`
Returns the status string for a coroutine.

### `coroutine.wrap(f)`
Creates a coroutine and returns a function that resumes it.

### `coroutine.yield(...)`
Suspends the running coroutine and returns values to the resumer.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- http://www.lua.org/manual/5.1/manual.html
