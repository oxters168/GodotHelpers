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
