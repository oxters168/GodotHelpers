class_name VectorHelpers

## Normalizes the given input vector then resizes it using the original magnitude up to 1
static func normalize_input(input_vector: Vector2):
	return input_vector.normalized() * min(input_vector.length(), 1)

## Returns the orthogonal projection of [param point] into a point in the plane represented by [param plane_normal]
static func project_on_plane(point: Vector3, plane_normal: Vector3) -> Vector3:
	return Plane(plane_normal).project(point)

## Calculates the percent a vector's direction is close to another vector's direction (1 for same, -1 for opposite, and 0 for perpendicular (so basically Vector3.dot but more correct in-betweens)).
static func percent_direction(vector: Vector3, other_vector: Vector3) -> float:
	return -(vector.normalized().angle_to(other_vector.normalized()) / (PI / 2) - 1)

## Converts the position from a Vector3 to a Vector3i given a step amount and offset
static func get_discrete_pos(pos: Vector3, space_step: Vector3, offset: Vector3 = Vector3.ZERO):
	var offsetted_pos = pos - offset
	return Vector3i(floor(offsetted_pos.x / space_step.x), floor(offsetted_pos.y / space_step.y), floor(offsetted_pos.z / space_step.z))

## Applies a power operation on all elements of the vector using the given power value
static func vec_pow(input_vector: Vector3, power: float):
	return Vector3(pow(input_vector.x, power), pow(input_vector.y, power), pow(input_vector.z, power))

## Calculates the shortest signed angle to reach a direction from another direction
static func get_shortest_signed_angle_2d(from: Vector2, to: Vector2) -> float:
	var requested_angle: float = to.angle_to(Vector2.UP)
	var current_angle: float = from.angle_to(Vector2.UP)
	var current_up_orientation: Quaternion = Quaternion(Vector3.UP, current_angle)
	var requested_up_orientation: Quaternion = Quaternion(Vector3.UP, requested_angle)
	var orientation_diff: Quaternion = requested_up_orientation * current_up_orientation.inverse()
	orientation_diff = QuatHelpers.shorten(orientation_diff)
	var angle_diff: float = orientation_diff.get_angle()
	var axis: Vector3 = orientation_diff.get_axis()
	return angle_diff * sign(axis.dot(Vector3.UP))
## Calculates the shortest signed angle to reach a direction from another direction where both directions lie on the same plane
static func get_shortest_signed_angle_3d(from: Vector3, to: Vector3, plane_normal: Vector3) -> float:
	var current_orientation: Quaternion = Quaternion(Basis.looking_at(from, plane_normal))
	var requested_orientation: Quaternion = Quaternion(Basis.looking_at(to, plane_normal))
	var orientation_diff: Quaternion = requested_orientation * current_orientation.inverse()
	orientation_diff = QuatHelpers.shorten(orientation_diff)
	var angle_diff: float = orientation_diff.get_angle()
	var axis: Vector3 = orientation_diff.get_axis()
	return angle_diff * sign(axis.dot(plane_normal))
## Gets the angle in degrees between from and to in the clockwise direction (2PI=same, PI=opposite, (PI/2)/(3PI/2)=perpendicular)
static func get_clockwise_angle_2d(from: Vector2, to: Vector2) -> float:
	var angle_offset: float = VectorHelpers.get_shortest_signed_angle_2d(from, to)
	if angle_offset < 0:
		angle_offset += 2 * PI
	return angle_offset
## Gets the angle in degrees between from and to in the clockwise direction (2PI=same, PI=opposite, (PI/2)/(3PI/2)=perpendicular)
static func get_clockwise_angle_3d(from: Vector3, to: Vector3, plane_normal: Vector3) -> float:
	var angle_offset: float = VectorHelpers.get_shortest_signed_angle_3d(from, to, plane_normal)
	if angle_offset < 0:
		angle_offset += 2 * PI
	return angle_offset

## If the input vector's magnitude exceeds the given value, then returns
## a vector in the same direction with the max magnitude, or else returns
## the same vector
## @param vec: The original vector</param>
## @param maxMagnitude: The maximum value of the magnitude</param>
## <returns>A vector with a magnitude that does not exceed the given max</returns>
static func max_mag(vec: Vector3, max_magnitude: float):
	if vec.length_squared() > max_magnitude * max_magnitude:
			vec = vec.normalized() * max_magnitude
	return vec

## If the input vector's magnitude exceeds the given value, then returns
## a vector in the same direction with the max magnitude, or else returns
## the same vector
## @param vec: The original vector</param>
## @param maxMagnitude: The maximum value of the magnitude</param>
## <returns>A vector with a magnitude that does not exceed the given max</returns>
static func max_mag2(vec: Vector2, max_magnitude: float):
	if vec.length_squared() > max_magnitude * max_magnitude:
			vec = vec.normalized() * max_magnitude
	return vec

## Checks if [param point] is within the segment defined by [param segment_start] and [param segment_end]
## Source: https://github.com/t-mw/citygen-godot/blob/master/scripts/math.gd
static func is_point_in_segment_range(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> bool:
	var vec := segment_end - segment_start
	var dot := (point - segment_start).dot(vec)
	return dot >= 0 && dot <= vec.length_squared()

## Calculates two vectors that are orthogonal to the given [param vector] and themselves. The resulting dictionary contains two
## vector values called [member normal_1] and [member normal_2].
## Source: https://stackoverflow.com/a/4341489
static func get_ortho_normals(vector: Vector3) -> Dictionary:
	var result: Dictionary = {}
	var w = Quaternion.from_euler(Vector3(PI / 2, 0, 0)) * vector
	if abs(vector.dot(w)) > 0.6:
		w = Quaternion.from_euler(Vector3(0, PI / 2, 0)) * vector
	w = w.normalized()
	result["normal_1"] = vector.cross(w).normalized()
	result["normal_2"] = vector.cross(result.normal_1).normalized()
	return result