# Math Library

These functions are shorthands for `math.*` in Lua 5.1. In WoW, the
trigonometry functions use degrees, not radians.

## Notes
- `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, and `atan2` in WoW take or return
degrees.
- `mod` is a legacy alias of `fmod`.
- `fastrandom` is a WoW-only faster random helper.

## Function summaries

### `abs(value)`
Returns the absolute value of a number.

### `acos(value)`
Returns the arc cosine of the value in degrees.

### `asin(value)`
Returns the arc sine of the value in degrees.

### `atan(value)`
Returns the arc tangent of the value in degrees.

### `atan2(y, x)`
Returns the arc tangent of `y / x` in degrees.

### `ceil(value)`
Returns the smallest integer that is greater than or equal to `value`.

### `cos(degrees)`
Returns the cosine of the angle in degrees.

### `deg(radians)`
Converts radians to degrees.

### `exp(value)`
Returns the exponential $e^{value}$.

### `floor(value)`
Returns the largest integer that is less than or equal to `value`.

### `fmod(value, modulus)`
Returns the remainder of `value / modulus`, rounding the quotient toward zero.

### `frexp(num)`
Splits a floating point number into mantissa and exponent.

### `ldexp(value, exponent)`
Returns `value * 2^exponent`.

### `log(value)`
Returns the natural logarithm of `value`.

### `log10(value)`
Returns the base-10 logarithm of `value`.

### `max(value[, values...])`
Returns the largest of the input values.

### `min(value[, values...])`
Returns the smallest of the input values.

### `mod(value, modulus)`
Legacy alias for `fmod`.

### `rad(degrees)`
Converts degrees to radians.

### `random([lower,] upper)`
Returns a random number. When bounds are provided, the result is a bounded
integer value.

### `sin(degrees)`
Returns the sine of the angle in degrees.

### `sqrt(value)`
Returns the square root of `value`.

### `tan(degrees)`
Returns the tangent of the angle in degrees.

### `fastrandom([lower,] upper)`
Returns a random number, faster than `random`.

## Sources
- https://warcraft.wiki.gg/wiki/Lua_functions
- http://www.lua.org/manual/5.1/manual.html
