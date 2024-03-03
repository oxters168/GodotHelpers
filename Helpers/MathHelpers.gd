class_name MathHelpers

## Truncates the decimal places of the given value to the desired amount
static func to_decimal_places(value: float, decimals: int) -> float:
	var multiplier = pow(10, decimals)
	return round(value * multiplier) / multiplier

## Generates a random angle from [param -limit] to [param limit] (inclusive)
## Source: https://github.com/t-mw/citygen-godot/blob/master/scripts/math.gd
static func random_angle(limit: float) -> float:
    # non-linear distribution
	var non_uniform_norm := pow(limit, 3)
	var val: float = 0
	while val == 0 || randf() < pow(val, 3) / non_uniform_norm:
		val = randf_range(-limit, +limit)
	return val

## Calculates the difference between the two given angles in degrees, the result will always be between 0 and 180
## Source: https://github.com/t-mw/citygen-godot/blob/master/scripts/math.gd
static func min_degree_difference(d1: float, d2: float) -> float:
	var diff := fmod(abs(d1 - d2), 180)
	return min(diff, abs(diff - 180))