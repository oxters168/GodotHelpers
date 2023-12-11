class_name CameraHelpers

## Returns the half height of the frustum at a given z distance from the camera
static func get_frustum_y_extent(cam: Camera3D, z: float):
	return tan(deg_to_rad(cam.fov / 2.0)) * z

## Returns the aspect ratio of the viewport as the width over the height
static func get_aspect_ratio(viewport: SubViewport):
	return (viewport.size.x as float) / viewport.size.y

## Returns a Vector2 object where the x value represents the half width of the frustum at a given z distance from the camera
## and the y value represents the half height of the frustum at a given z distance from the camera
static func get_frustum_extents(cam: Camera3D, z: float, aspect_ratio: float):
	var y = get_frustum_y_extent(cam, z)
	var x = y * aspect_ratio
	return Vector2(x, y)