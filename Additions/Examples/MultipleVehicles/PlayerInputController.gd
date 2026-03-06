extends Node3D
class_name PlayerInputController

@export var target: Node3D
@export var camera: OrbitCamera
@export var ocean: Ocean

func _process(_delta: float) -> void:
	var vehicle: Vehicle
	if target:
		vehicle = NodeHelpers.get_child_of_type(target, Vehicle)
		var dialogic = ScriptHelpers.get_global_autoload("Dialogic")
		var is_dialogic_timeline_running: bool = dialogic and dialogic.current_timeline != null
		if vehicle and not is_dialogic_timeline_running:
			vehicle.set_input_axis(Vehicle.InputAxis.VERTICAL_AXIS, Input.get_axis("move_ver_neg", "move_ver_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.HORIZONTAL_AXIS, Input.get_axis("move_hor_neg", "move_hor_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.DRIVE_AXIS, Input.get_axis("brake", "gas"))
			vehicle.set_input_axis(Vehicle.InputAxis.YAW_AXIS, Input.get_axis("move_lat_neg", "move_lat_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.PITCH_AXIS, Input.get_axis("move_ver_neg", "move_ver_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.LIFT_AXIS, Input.get_action_strength("lift"))
			vehicle.set_input_button(Vehicle.InputButton.JUMP_BTN, Input.is_action_pressed("jump"))
			vehicle.set_input_button(Vehicle.InputButton.OCCUPY_BTN, Input.is_action_pressed("occupy"))
			vehicle.set_input_button(Vehicle.InputButton.ATTACH_BTN, Input.is_action_pressed("attach"))
			vehicle.set_camera(camera)
	
	var adjusted_target: Node3D = target
	if vehicle:
		adjusted_target = (vehicle._occupying if vehicle._occupying else adjusted_target)
	if camera:
		camera.input_look_vector = Vector2(Input.get_axis("look_hor_neg", "look_hor_pos"), Input.get_axis("look_ver_neg", "look_ver_pos"))
		camera.target = adjusted_target
	if ocean:
		ocean.target = adjusted_target
