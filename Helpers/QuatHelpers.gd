class_name QuatHelpers

## Converts a quaternion into a rotation based on an angle around an axis
## The returned object contains a key for 'axis' and a key for 'angle'
static func get_axis_angle(quat_change: Quaternion) -> Dictionary:
	var r_angle = 2 * acos(quat_change.w)
	var r = (1.0) / sqrt(1 - quat_change.w * quat_change.w)
	var r_axis = Vector3(quat_change.x * r, quat_change.y * r, quat_change.z * r)
	return { 'axis': r_axis, 'angle': r_angle }

## If the quaternion is going the long way around the axis, then this function will
## find the complementary shorter angle on the axis
static func shorten(value: Quaternion) -> Quaternion:
	# Source: https://answers.unity.com/questions/147712/what-is-affected-by-the-w-in-quaternionxyzw.html
	# "If w is -1 the quaternion defines +/-2pi rotation angle around an undefined axis"
	# So by doing this we check to see if that is true, and if so turn it the other way around
	var clone = Quaternion(value)
	if (value.w < 0):
		clone = Quaternion(-value.x, -value.y, -value.z, -value.w)
	return clone

## Gets the angle in radians of the quaternion only along the specified axis, will always return a value between -PI and PI
## Source: https://stackoverflow.com/questions/3684269/component-of-a-quaternion-rotation-around-an-axis
static func poll_axis_signed_angle(rot: Quaternion, axis: Vector3, axis_normal: Vector3) -> float:
	var transformed: Vector3 = rot * axis_normal
	# Project transformed vector onto plane
	var flattened: Vector3 = (transformed - (transformed.dot(axis) * axis)).normalized()
	var direction = sign(axis_normal.cross(flattened).dot(axis))
	# Get angle between original vector and projected transform to get angle around normal
	var angle: float = direction * acos(axis_normal.dot(flattened))
	return angle
## Gets the angle in radians of the quaternion only along the specified axis
## Source: https://stackoverflow.com/questions/3684269/component-of-a-quaternion-rotation-around-an-axis
static func poll_axis_angle(rot: Quaternion, axis: Vector3, axis_normal: Vector3) -> float:
	axis = axis.normalized()
	var transformed: Vector3 = rot * axis_normal
	# Project transformed vector onto plane
	var flattened: Vector3 = (transformed - (transformed.dot(axis) * axis)).normalized()
	# Get angle between original vector and projected transform to get angle around normal
	var angle: float = acos(axis_normal.dot(flattened))
	return angle

## Converts a rotation from the local space of the parent to a rotation in the same space the parent is currently in
static func to_global(parent_global_rot: Quaternion, local_rotation: Quaternion) -> Quaternion:
	return parent_global_rot * local_rotation
## Converts a rotation existing in the same space as the parent into a rotation in the local space of the parent
static func to_local(parent_global_rot: Quaternion, global_rotation: Quaternion) -> Quaternion:
	return parent_global_rot.inverse() * global_rotation