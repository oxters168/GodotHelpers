@tool
extends Camera3D
class_name OrbitCamera

enum Action { LOOK_HOR_POS, LOOK_HOR_NEG, LOOK_VER_POS, LOOK_VER_NEG, LOOK_BTN }

## Distance between camera and target
@export var distance: float = 5.0
## Current angle of camera on each axis in degrees
@export var angle: Vector3 = Vector3()
## Whether to limit the camera angles between a min and max value
var limit_angle: bool = false:
	set(value):
		limit_angle = value
		notify_property_list_changed()
## The minimum angle in degrees value of each axis, only works if limit_angle is set to true
var min_angle: Vector3 = Vector3.ONE * -360
## The maximum angle in degrees value of each axis, only works if limit_angle is set to true
var max_angle: Vector3 = Vector3.ONE * 360
## Multiplier applied to look_input when being added to angle
@export var look_sensitivity: float = 1.0
## How much to linearly offset the camera from where it will orbit the target
@export var offset: Vector3 = Vector3()
## Should the offset be calculated within the target's local space
@export var offset_locally: bool = false
## If set to true then the camera will collide with other physics bodies
@export var abide_to_physics: bool = false
## Should the camera also avoid the target when camera is abiding to physics
@export var exclude_target: bool = true
## How much to move to the final position each frame. The value 1 would mean move
## to the final position, 0.5 would mean go halfway each frame, and 0 would mean
## do not move at all (therefore it is excluded).
@export_range (0.001, 1) var linear_lerp: float = 1
## The target to orbit
@export var target: Node3D
## Show camera information
@export var debug: bool = false

## Whether the look button is pressed or not
var look_btn: bool
## The vector that drives the camera orbit rotation
var input_look_vector: Vector2
## The final input vector
var _input_vector: Vector2 = Vector2.ZERO

## Should mouse input control the camera orientation
var mouse_input_enabled: bool = false:
	set(value):
		mouse_input_enabled = value
		notify_property_list_changed()
# @export_category("Input")
## Should [member input_look_vector] control the camera orientation
var look_input_enabled: bool:
	set(value):
		look_input_enabled = value
		notify_property_list_changed()
## Should a button be required to be held to allow for the input to control the camera orientation
var look_btn_enabled: bool:
	set(value):
		look_btn_enabled = value
		notify_property_list_changed()
## Should the button required to be held to control the camera orientation only apply to mouse input
var look_btn_mouse_exclusive: bool

## Helpful when need to know what a property needs
## https://forum.godotengine.org/t/where-can-i-find-more-hidden-get-property-list-functionality-for-arrays-or-other-types/9846/3
func _get_property_list():
	var property_list: Array = []
	property_list.append(PropertyHelpers.create_category_property("Limit Angle"))
	property_list.append(PropertyHelpers.create_toggle_property(&"limit_angle"))
	if limit_angle:
		property_list.append(PropertyHelpers.create_vector3_property(&"min_angle"))
		property_list.append(PropertyHelpers.create_vector3_property(&"max_angle"))

	property_list.append(PropertyHelpers.create_category_property("Input"))
	property_list.append(PropertyHelpers.create_toggle_property(&"look_input_enabled"))
	property_list.append(PropertyHelpers.create_toggle_property(&"mouse_input_enabled"))

	# var action_keys: Array = Action.keys()
	if look_input_enabled:
		property_list.append(PropertyHelpers.create_toggle_property(&"look_btn_enabled"))
		if look_btn_enabled and mouse_input_enabled:
			property_list.append(PropertyHelpers.create_toggle_property(&"look_btn_mouse_exclusive"))
	return property_list

func _init(init_angle: Vector3 = Vector3.ZERO, init_pos: Vector3 = Vector3.ZERO):
	if not Engine.is_editor_hint():
		angle = init_angle
		position = init_pos

func _input(event):
	if not Engine.is_editor_hint():
		if mouse_input_enabled && event is InputEventMouseMotion:
			if not look_btn_enabled or (look_btn_enabled && look_btn):
				var mouse_diff = -event.relative
				_input_vector += VectorHelpers.normalize_input(mouse_diff)

func _physics_process(_delta):
	if not Engine.is_editor_hint():
		var modded_input = _input_vector * 4.0 * look_sensitivity
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
			if target && exclude_target:
				excludedRids = [target.get_rid()]
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

		if (look_btn_enabled and look_btn_mouse_exclusive) or (not look_btn_enabled):
			_input_vector = input_look_vector
			_input_vector = Vector2(-_input_vector.x, _input_vector.y)
		else:
			_input_vector = Vector2.ZERO

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
