extends Node3D
class_name PlayerInputController

@export var target: Node3D
@export var camera: OrbitCamera

func _process(_delta: float) -> void:
	var vehicle: Vehicle
	if target:
		vehicle = NodeHelpers.get_child_of_type(target, Vehicle)
		if vehicle:
			vehicle.set_input_axis(Vehicle.InputAxis.VERTICAL_AXIS, Input.get_axis("move_ver_neg", "move_ver_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.HORIZONTAL_AXIS, Input.get_axis("move_hor_neg", "move_hor_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.YAW_AXIS, Input.get_axis("move_lat_neg", "move_lat_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.PITCH_AXIS, Input.get_axis("move_ver_neg", "move_ver_pos"))
			vehicle.set_input_axis(Vehicle.InputAxis.LIFT_AXIS, Input.get_action_strength("look_ver_pos"))
			vehicle.set_input_button(Vehicle.InputButton.JUMP_BTN, Input.is_action_pressed("look_ver_pos"))
			vehicle.set_input_button(Vehicle.InputButton.OCCUPY_BTN, Input.is_action_pressed("occupy"))
			vehicle.set_camera(camera)
	if camera:
		var adjusted_target: Node3D = target
		if vehicle:
			adjusted_target = (vehicle._occupying if vehicle._occupying else adjusted_target)
		camera.target = adjusted_target
