# String Library

These helpers are shorthands for `string.*` and are also available as global
functions in the WoW client.

## Notes
- Method-call syntax is documented in STRING_DETAILS.md.
- `strrev` is an alias of `string.reverse`.

## Standard string helpers

### `format(formatString[, value[, ...]])`
Returns a formatted string built from the format string and values.

### `gmatch(string, pattern)`
Returns an iterator that yields successive pattern matches from the string.

### `gsub(string, pattern, replacement[, limitCount])`
Returns a copy of the string where matches are replaced by `replacement`.

### `strbyte(string[, index])`
Returns the numeric byte value of the character at `index`.

### `strchar(asciiCode[, ...])`
Creates a string from the given numeric character codes.

### `strfind(string, pattern[, initpos[, plain]])`
Searches for `pattern` in the string, optionally starting at `initpos` or using
plain substring matching.

### `strlen(string)`
Returns the length of the string in bytes.

### `strlower(string)`
Returns the string with all letters converted to lower case.

### `strmatch(string, pattern[, initpos])`
Returns the matched substring(s) for `pattern`.

### `strrep(seed, count)`
Returns a string that repeats `seed` `count` times.

### `strrev(string)`
Returns the string in reverse order.

### `strsub(string, index[, endIndex])`
Returns a substring starting at `index` and ending at `endIndex` if provided.

### `strupper(string)`
Returns the string with all letters converted to upper case.

## WoW-only string helpers

### `strcmputf8i(a, b)`
Compares two strings using UTF-8 character boundaries.

### `strlenutf8(string)`
Returns the number of UTF-8 characters in a string.

### `strtrim(string[, chars])`
Trims leading and trailing whitespace or the characters in `chars`.

### `strsplit(delimiter, string[, pieces])`
Splits a string on a delimiter and returns the pieces as multiple values.

### `strsplittable(delimiter, subject[, pieces])`
Splits a string on a delimiter and returns the pieces in a table.

### `strjoin(delimiter, string, string[, ...])`
Joins multiple strings with the given delimiter.

### `strconcat(...)`
Concatenates all number or string arguments into a single string.

### `tostringall(...)`
Converts all arguments to strings and returns them in order.

## FrameXML-only helper

### `string.rtgsub(s, pattern, repl[, n])`
Variant of `string.gsub` that can accept restricted tables.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- http://www.lua.org/manual/5.1/manual.html
