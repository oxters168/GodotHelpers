class_name MathHelpers

## Truncates the decimal places of the given value to the desired amount
static func to_decimal_places(value: Variant, decimals: int) -> Variant:
	var multiplier = pow(10, decimals)
	var format_num: Callable = func(num: float) -> float: return (round(num * multiplier) / multiplier)
	if (value is float):
		return format_num.call(value)
	elif (value is Vector2):
		return Vector2(format_num.call(value.x), format_num.call(value.y))
	elif (value is Vector3):
		return Vector3(format_num.call(value.x), format_num.call(value.y), format_num.call(value.z))
	else:
		printerr("Received bad value type (", value.VariantType, ") in 'to_decimal_places', only supports float, Vector2, and Vector3")
		return value

static func print_format(value: Variant, decimals: int = 2) -> String:
	var neg_space: Callable = func(num: float) -> String: return str(" ", num) if num >= 0 else str(num)
	if (value is int):
		return neg_space.call(value)
	elif (value is float):
		return neg_space.call(to_decimal_places(value, decimals))
	elif (value is Vector2):
		return str("(", neg_space.call(to_decimal_places(value.x, decimals)), ", ", neg_space.call(to_decimal_places(value.y, decimals)), ")")
	elif (value is Vector3):
		return str("(", neg_space.call(to_decimal_places(value.x, decimals)), ", ", neg_space.call(to_decimal_places(value.y, decimals)), ", ", neg_space.call(to_decimal_places(value.z, decimals)), ")")
	else:
		printerr("Received bad value type (", value.VariantType, ") in 'print_format', only supports int, float, Vector2, and Vector3")
		return str(value)
	
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