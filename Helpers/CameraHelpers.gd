class_name CameraHelpers

## Returns the half the width/height (depending on what the [member Camera3D.keep_aspect] value is set to) of the frustum at
## a given z distance from the camera
static func get_frustum_aspect_extent(cam: Camera3D, z: float) -> float:
	return tan(deg_to_rad(cam.fov / 2.0)) * z

## Returns the aspect ratio of the camera's nearest parent viewport as the width over the height
static func get_aspect_ratio(cam: Camera3D) -> float:
	var size = cam.get_viewport().size
	return (size.x as float) / size.y

## Returns a Vector2 object where the x value represents the half width of the frustum at a given z distance from the camera
## and the y value represents the half height of the frustum at a given z distance from the camera. If the camera is an ortho
## camera then the z value is not needed.
static func get_frustum_extents(cam: Camera3D, z: float = 0) -> Vector2:
	var aspect_ratio = get_aspect_ratio(cam)
	if cam.projection == Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
		var y = 0
		var x = 0
		if cam.keep_aspect == Camera3D.KeepAspect.KEEP_WIDTH:
			x = get_frustum_aspect_extent(cam, z)
			y = x / aspect_ratio
		else:
			y = get_frustum_aspect_extent(cam, z)
			x = y * aspect_ratio
		return Vector2(x, y)
	elif cam.projection == Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
		var ortho_size = cam.size
		if cam.keep_aspect == Camera3D.KeepAspect.KEEP_WIDTH:
			return Vector2(ortho_size, ortho_size / aspect_ratio) / 2
		else:
			return Vector2(ortho_size * aspect_ratio, ortho_size) / 2
	else:
		push_error("get_frustum_extents currently unsupported for given camera type ", cam.projection)
		return Vector2.ZERO

## Calculates how much the given world size covers the viewport in pixels, where the given world size x and y represent a distance
## along the camera's respective axes and the z represents the distance from the camera
static func world_to_viewport_size(cam: Camera3D, world_size: Vector3) -> Vector2:
	var viewport_size = cam.get_viewport().size
	var frustum_world_size = get_frustum_extents(cam, world_size.z) * 2
	var normalized = Vector2(world_size.x / frustum_world_size.x, world_size.y / frustum_world_size.y)
	# don't know why this works but it was necessary to get the proper size in an orthogonal setting, untested in perspective
	# I very much dislike this solution as it is hand wavy, any alternative would be better if found
	var magic_multiplier = Vector2(1 + ((1 / world_size.x) * 0.9), 1 + ((1 / world_size.y) * 0.9))
	var output = Vector2((normalized.x * viewport_size.x) * magic_multiplier.x, (normalized.y * viewport_size.y) * magic_multiplier.y)
	# print(world_size, " / ", frustum_world_size, " => ", normalized, " * ", viewport_size, " => ", output)
	return output

## For debugging purposes, shows a diagonal line going from the top left corner to the bottom right corner of the camera frustum
## and a line going from the bottom left corner to the top right corner and the edges of the camera frustum at the given distance
static func display_frustum_at(cam: Camera3D, z: float, color: Color = Color.WHITE, linger_frames: int = 0):
	var frustum_extents = get_frustum_extents(cam, z)
	var cam_forward = NodeHelpers.get_global_forward(cam)
	var cam_right = NodeHelpers.get_global_right(cam)
	var cam_down = NodeHelpers.get_global_down(cam)
	var relative_frustum_right = cam_right * frustum_extents.x
	var relative_frustum_down = cam_down * frustum_extents.y

	var top_left_corner = cam.position + cam_forward * z - relative_frustum_right - relative_frustum_down
	var bottom_right_corner = cam.position + cam_forward * z + relative_frustum_right + relative_frustum_down
	var bottom_left_corner = cam.position + cam_forward * z - relative_frustum_right + relative_frustum_down
	var top_right_corner = cam.position + cam_forward * z + relative_frustum_right - relative_frustum_down
	# top left to bottom right diagonal
	DebugDraw.draw_line_3d(bottom_right_corner, top_left_corner, color, linger_frames)
	# bottom left to top right diagonal
	DebugDraw.draw_line_3d(bottom_left_corner, top_right_corner, color, linger_frames)
	# left edge
	DebugDraw.draw_line_3d(bottom_left_corner, top_left_corner, color, linger_frames)
	# right edge
	DebugDraw.draw_line_3d(bottom_right_corner, top_right_corner, color, linger_frames)
	# top edge
	DebugDraw.draw_line_3d(top_left_corner, top_right_corner, color, linger_frames)
	# bottom edge
	DebugDraw.draw_line_3d(bottom_left_corner, bottom_right_corner, color, linger_frames)
