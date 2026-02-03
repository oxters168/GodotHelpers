@tool
extends Camera3D
class_name FreeCamera

## Should mouse input control the camera orientation
@export var mouse_input: bool = false
## Current angle of camera on each axis in degrees
@export var angle = Vector3()
## Whether to limit the camera angles between a min and max value
var limit_angle: bool = false:
	set(value):
		limit_angle = value
		notify_property_list_changed()
## The minimum angle value of each axis, only works if limit_angle is set to true
var min_angle: Vector3 = Vector3.ONE * -360
## The maximum angle value of each axis, only works if limit_angle is set to true
var max_angle: Vector3 = Vector3.ONE * 360
## Multiplier applied to look_input when being added to angle
@export var look_sensitivity = 1.0
## The max linear speed of the camera
@export var speed: float = 5.0
## Show camera information
@export var debug: bool = false
## Stores the input received from the mouse or from the following inputs if they are set:
## "look_hor_neg", "look_hor_pos", "look_ver_neg", "look_ver_pos"
var look_input = Vector2()
## Stores the input received from the following inputs if they are set:
## "move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos"
var move_input = Vector2()
## Stores the input received from the following inputs if they are set:
## "move_lat_neg", "move_lat_pos"
var move_lat_input: float = 0

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append(PropertyHelpers.create_category_property("Limit Angle"))
	property_list.append(PropertyHelpers.create_toggle_property(&"limit_angle"))
	if limit_angle:
		property_list.append(PropertyHelpers.create_vector3_property(&"min_angle"))
		property_list.append(PropertyHelpers.create_vector3_property(&"max_angle"))
	return property_list

func _init(set_angle: bool = false, init_angle: Vector3 = Vector3.ZERO, set_pos: bool = false, init_pos: Vector3 = Vector3.ZERO):
	if set_angle:
		angle = init_angle
	if set_pos:
		position = init_pos

func _input(event):
	if not Engine.is_editor_hint():
		if mouse_input && event is InputEventMouseMotion:
			var mouse_diff = -event.relative
			look_input = VectorHelpers.normalize_input(look_input + mouse_diff)

func _physics_process(delta):
	if not Engine.is_editor_hint():
		var modded_input = look_input * 4.0 * look_sensitivity
		angle = Vector3(fmod(angle.x + modded_input.y, 360), fmod(angle.y + modded_input.x, 360), fmod(angle.z, 360.0))
		if (limit_angle):
			angle = Vector3(min(max(angle.x, min_angle.x), max_angle.x), min(max(angle.y, min_angle.y), max_angle.y), min(max(angle.z, min_angle.z), max_angle.z))
		var angle_rad = Vector3(deg_to_rad(angle.x), deg_to_rad(angle.y), deg_to_rad(angle.z))
		if debug:
			DebugDraw.set_text("CamAngle", angle)
		var rot = (Quaternion(Vector3.UP, angle_rad.y) * Quaternion(Vector3.RIGHT, angle_rad.x)) * Quaternion(Vector3.BACK, angle_rad.z)
		
		global_transform.basis = Basis(rot)
		global_transform.origin = global_transform.origin + NodeHelpers.get_global_back(self) * (move_input.y * speed * delta) + NodeHelpers.get_global_left(self) * (move_input.x * speed * delta) + NodeHelpers.get_global_up(self) * (move_lat_input * speed * delta)
		if debug:
			DebugDraw.set_text("CamPos", global_transform.origin)
		
		look_input = Input.get_vector("look_hor_neg", "look_hor_pos", "look_ver_neg", "look_ver_pos") # needs to be at the end since I also want mouse input to affect the camera
		look_input = Vector2(-look_input.x, look_input.y)
		move_input = Input.get_vector("move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos")
		move_lat_input = Input.get_axis("move_lat_neg", "move_lat_pos")
