class_name QuatHelpers

## Converts a quaternion into a rotation based on an angle around an axis
## The returned object contains a key for 'axis' and a key for 'angle'
static func get_axis_angle(quat_change: Quaternion):
	var r_angle = 2 * acos(quat_change.w)
	var r = (1.0) / sqrt(1 - quat_change.w * quat_change.w)
	var r_axis = Vector3(quat_change.x * r, quat_change.y * r, quat_change.z * r)
	return { 'axis': r_axis, 'angle': r_angle }