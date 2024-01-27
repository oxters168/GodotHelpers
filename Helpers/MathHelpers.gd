class_name MathHelpers

static func to_decimal_places(value: float, decimals: int) -> float:
	var multiplier = pow(10, decimals)
	return round(value * multiplier) / multiplier