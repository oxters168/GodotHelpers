class_name VectorHelpers

## Normalizes the given input vector then resizes it using the original magnitude up to 1
static func normalize_input(input_vector: Vector2):
	return input_vector.normalized() * min(input_vector.length(), 1)

## Converts the position from a Vector3 to a Vector3i given a step amount and offset
static func get_discrete_pos(pos: Vector3, space_step: Vector3, offset: Vector3 = Vector3.ZERO):
	var offsetted_pos = pos - offset
	return Vector3i(floor(offsetted_pos.x / space_step.x), floor(offsetted_pos.y / space_step.y), floor(offsetted_pos.z / space_step.z))

## Applies a power operation on all elements of the vector using the given power value
static func vec_pow(input_vector: Vector3, power: float):
	return Vector3(pow(input_vector.x, power), pow(input_vector.y, power), pow(input_vector.z, power))

## If the input vector's magnitude exceeds the given value, then returns
## a vector in the same direction with the max magnitude, or else returns
## the same vector
## @param vec: The original vector</param>
## @param maxMagnitude: The maximum value of the magnitude</param>
## <returns>A vector with a magnitude that does not exceed the given max</returns>
static func max_mag(vec: Vector3, maxMagnitude: float):
	if vec.length_squared() > maxMagnitude * maxMagnitude:
			vec = vec.normalized() * maxMagnitude
	return vec

## If the input vector's magnitude exceeds the given value, then returns
## a vector in the same direction with the max magnitude, or else returns
## the same vector
## @param vec: The original vector</param>
## @param maxMagnitude: The maximum value of the magnitude</param>
## <returns>A vector with a magnitude that does not exceed the given max</returns>
static func max_mag2(vec: Vector2, maxMagnitude: float):
	if vec.length_squared() > maxMagnitude * maxMagnitude:
			vec = vec.normalized() * maxMagnitude
	return vec