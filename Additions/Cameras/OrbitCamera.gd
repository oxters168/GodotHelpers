extends Camera3D
class_name OrbitCamera

## Should mouse input control the camera orientation
@export var mouse_input: bool = false
## Distance between camera and target
@export var distance: float = 5.0
## Current angle of camera on each axis in degrees
@export var angle: Vector3 = Vector3()
## Whether to limit the camera angles between a min and max value
@export var limit_angle: bool = false
## The minimum angle in degrees value of each axis, only works if limit_angle is set to true
@export var min_angle: Vector3 = Vector3.ONE * -360
## The maximum angle in degrees value of each axis, only works if limit_angle is set to true
@export var max_angle: Vector3 = Vector3.ONE * 360
## Multiplier applied to look_input when being added to angle
@export var look_sensitivity: float = 1.0
## How much to linearly offset the camera from where it will orbit the target
@export var offset: Vector3 = Vector3()
## Should the offset be calculated within the target's local space
@export var offset_locally: bool = false
## If set to true then the camera will collide with other physics bodies
@export var abide_to_physics: bool = false
## How much to move to the final position each frame. The value 1 would mean move
## to the final position, 0.5 would mean go halfway each frame, and 0 would mean
## do not move at all (therefore it is excluded).
@export_range (0.001, 1) var linear_lerp: float = 1
## The target to orbit
@export var target: Node3D
## Show camera information
@export var debug: bool = false
## Stores the input received from the mouse or from the following inputs if they are set:
## "look_hor_neg", "look_hor_pos", "look_ver_neg", "look_ver_pos"
var input_vector: Vector2 = Vector2()

func _init(init_angle: Vector3 = Vector3.ZERO, init_pos: Vector3 = Vector3.ZERO):
	angle = init_angle
	position = init_pos

func _input(event):
	if mouse_input && event is InputEventMouseMotion:
		var mouse_diff = -event.relative
		input_vector = VectorHelpers.normalize_input(input_vector + mouse_diff)

func _physics_process(_delta):
	var modded_input = input_vector * 4.0 * look_sensitivity
	angle = Vector3(fmod(angle.x + modded_input.y, 360), fmod(angle.y + modded_input.x, 360), fmod(angle.z, 360.0))
	if limit_angle:
		angle = Vector3(min(max(angle.x, min_angle.x), max_angle.x), min(max(angle.y, min_angle.y), max_angle.y), min(max(angle.z, min_angle.z), max_angle.z))
	var angle_rad = Vector3(deg_to_rad(angle.x), deg_to_rad(angle.y), deg_to_rad(angle.z))
	if debug:
		DebugDraw.set_text("CamAngle", angle)
	var rot = (Quaternion(Vector3.UP, angle_rad.y) * Quaternion(Vector3.RIGHT, angle_rad.x)) * Quaternion(Vector3.BACK, angle_rad.z)
	
	var origin = Vector3.ZERO + offset
	if target:
		var actual_offset = offset
		if offset_locally:
			actual_offset = target.global_transform.basis * offset
		origin = target.global_transform.origin + actual_offset
	
	# checking for obstacles in between the camera and the target
	var cam_dir = rot * Vector3.BACK
	var final_pos = origin + cam_dir * distance
	if abide_to_physics:
		if debug:
			DebugDraw.draw_ray_3d(origin, cam_dir, 5, Color.BLACK)
		# exclude ourselves from the physics check
		var excludedRids: Array = []
		if target:
			excludedRids = NodeHelpers.get_children_of_type(target, CollisionObject3D).map(func(col): return col.get_rid())
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, origin + cam_dir * distance, ~0, excludedRids)
		var result = space_state.intersect_ray(query)
		
		if result:
			var col_obj = result.collider
			var col_pnt = result.position			
			var cam_frustum_y = CameraHelpers.get_frustum_aspect_extent(self, near)
			var decreased_dist = (col_pnt - origin).length()
			var frustum_push_dist = abs(cam_frustum_y / tan(deg_to_rad(angle.x))) + near
			if debug:
				DebugDraw.draw_line_3d(origin, col_pnt, Color.RED)
				DebugDraw.set_text("CameraObst", str(col_obj) + ", " + str(cam_frustum_y) + " => " + str(frustum_push_dist))
			final_pos = origin + cam_dir * max(decreased_dist - frustum_push_dist, 0)
	
	global_transform.basis = Basis(rot)
	global_transform.origin = lerp(global_transform.origin, final_pos, linear_lerp)

	input_vector = Input.get_vector("look_hor_neg", "look_hor_pos", "look_ver_neg", "look_ver_pos"); # needs to be at the end since I also want mouse input to affect the camera
	input_vector = Vector2(-input_vector.x, input_vector.y)

## Set the angle limits of the camera, the given values should be in degrees
func set_angle_limit(angle_min: Vector3, angle_max: Vector3):
	limit_angle = true
	min_angle = angle_min
	max_angle = angle_max
## Unset any angle limits that were set previously on the camera
func unset_angle_limit():
	limit_angle = false
	min_angle = Vector3.ONE * -360
	max_angle = Vector3.ONE * -360
