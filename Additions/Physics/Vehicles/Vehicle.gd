extends Node3D
## This class is not meant to be used directly but is automatically created
## by vehicles as a child
class_name Vehicle

enum VehicleType {
	NONE = 0x0,
	FORCE_DRIVEN_CHARACTER = 0x1,
	CAR = 0x2,
	SPEED_BOAT = 0x4,
	HELICOPTER = 0x8,
}
enum InputAxis {
	VERTICAL_AXIS,   ## forward/backward
	HORIZONTAL_AXIS, ## left/right
  DRIVE_AXIS,      ## gas/brake
	YAW_AXIS,        ## rotate left/right
	PITCH_AXIS,      ## pitch forward/back
	LIFT_AXIS,       ## lift strength
}
enum InputButton {
	JUMP_BTN,
	OCCUPY_BTN, ## enter/exit
}

var _vehicle: Node3D

var _occupying: Vehicle
var _occupied_seats: Array[Vehicle] = []

var _axes_warned: Array[InputAxis] = []
var _btns_warned: Array[InputButton] = []
var _no_vehicle_axis_warned: bool
var _no_vehicle_btn_warned: bool
var _no_cam_warned: bool

var _prev_occupy_btn: bool

func _init(vehicle: Node3D) -> void:
	_vehicle = vehicle

func add_occupant(occupant: Vehicle) -> bool:
	if _occupied_seats.size() < _vehicle.occupant_info.occupant_seats:
		occupant._occupying = self
		_occupied_seats.append(occupant)
		occupant._vehicle.visible = false
		occupant._vehicle.process_mode = Node.PROCESS_MODE_DISABLED
		return true
	else:
		return false
func remove_occupant(occupant: Vehicle) -> bool:
	if _occupied_seats.has(occupant):
		var exit_spots: Array[Vector3] = occupant._occupying._vehicle.occupant_info.exit_spots
		occupant._vehicle.global_position = occupant._occupying._vehicle.to_global(exit_spots[_occupied_seats.find(occupant)])
		occupant._occupying = null
		_occupied_seats.erase(occupant)
		occupant._vehicle.process_mode = Node.PROCESS_MODE_INHERIT
		occupant._vehicle.visible = true
		return true
	else:
		return false
func has_occupant(occupant: Vehicle) -> bool:
	return _occupied_seats.has(occupant)

func set_input_axis(input_axis: InputAxis, value: float) -> void:
	var controlled_vehicle: Node3D = (_occupying._vehicle if _occupying else _vehicle)
	if controlled_vehicle is Car:
		var car: Car = controlled_vehicle as Car
		match input_axis:
			InputAxis.DRIVE_AXIS:
				car.input_vector = Vector2(car.input_vector.x, value)
			InputAxis.HORIZONTAL_AXIS:
				car.input_vector = Vector2(value, car.input_vector.y)
			_: _warn_axis(input_axis)
	elif controlled_vehicle is SpeedBoat:
		var speedboat: SpeedBoat = controlled_vehicle as SpeedBoat
		match input_axis:
			InputAxis.DRIVE_AXIS:
				speedboat.input_vector = Vector2(speedboat.input_vector.x, value)
			InputAxis.HORIZONTAL_AXIS:
				speedboat.input_vector = Vector2(value, speedboat.input_vector.y)
			_: _warn_axis(input_axis)
	elif controlled_vehicle is ForceDrivenCharacter3D:
		var character: ForceDrivenCharacter3D = controlled_vehicle as ForceDrivenCharacter3D
		match input_axis:
			InputAxis.VERTICAL_AXIS:
				character.input_vector = Vector2(character.input_vector.x, value)
			InputAxis.HORIZONTAL_AXIS:
				character.input_vector = Vector2(value, character.input_vector.y)
			_: _warn_axis(input_axis)
	elif controlled_vehicle is Helicopter:
		var helicopter: Helicopter = controlled_vehicle as Helicopter
		match input_axis:
			InputAxis.PITCH_AXIS:
				helicopter.input_tilt_vector = Vector2(helicopter.input_tilt_vector.x, value)
			InputAxis.HORIZONTAL_AXIS:
				helicopter.input_tilt_vector = Vector2(value, helicopter.input_tilt_vector.y)
			InputAxis.YAW_AXIS:
				helicopter.input_rot = value
			InputAxis.LIFT_AXIS:
				helicopter.input_lift = value
			_: _warn_axis(input_axis)
	else:
		if not _no_vehicle_axis_warned:
			_no_vehicle_axis_warned = true
			push_warning(str(_vehicle.get_script().get_global_name(), " axis input is unsupported (only support for Car, ForceDrivenCharacter3D, Helicopter, and SpeedBoat"))

func set_input_button(input_btn: InputButton, value: bool) -> void:
	if input_btn == InputButton.OCCUPY_BTN:
		var local_bounds: AABB = BoundsHelpers.get_total_bounds_3d(_vehicle, true)
		var global_bounds: AABB = BoundsHelpers.get_total_bounds_3d(_vehicle, true, true)
		var radius: float = (max(local_bounds.size.x, local_bounds.size.y, local_bounds.size.z) / 2) * 1.5
		if value:
			DebugDraw.draw_circle_3d(global_bounds.get_center(), CameraHelpers.get_active_camera_3d().global_basis.get_rotation_quaternion(), radius, Color.BLUE)
		if not value and _prev_occupy_btn:
			if _occupying:
				_occupying.remove_occupant(self)
			else:
				var results: Array[Dictionary] = PhysicsHelpers.intersect_sphere(global_bounds.get_center(), radius, get_world_3d(), false, true, 32, [_vehicle.get_rid()])
				var vehicle_to_occupy: Vehicle = null
				for result in results:
					vehicle_to_occupy = NodeHelpers.get_child_of_type(result["collider"], Vehicle)
					if vehicle_to_occupy:
						DebugDraw.set_text("Occupy", result["collider"])
						break
				if vehicle_to_occupy:
					var can_occupy: int = _vehicle.occupant_info.can_occupy
					var other_type: VehicleType = vehicle_to_occupy.get_vehicle_type()
					if (can_occupy & other_type) == other_type:
						vehicle_to_occupy.add_occupant(self)
		_prev_occupy_btn = value
	
	var controlled_vehicle: Node3D = (_occupying._vehicle if _occupying else _vehicle)
	if controlled_vehicle is ForceDrivenCharacter3D:
		var character: ForceDrivenCharacter3D = controlled_vehicle as ForceDrivenCharacter3D
		match input_btn:
			InputButton.JUMP_BTN:
				character.jump_btn = value
			_: _warn_btn(input_btn)
	else:
		if not _no_vehicle_btn_warned:
			_no_vehicle_btn_warned = true
			push_warning(str(controlled_vehicle.get_script().get_global_name(), " button input is unsupported (only support for ForceDrivenCharacter3D"))

func set_camera(camera: Node3D) -> void:
	var controlled_vehicle: Node3D = (_occupying._vehicle if _occupying else _vehicle)
	if controlled_vehicle != _vehicle:
		if _vehicle is ForceDrivenCharacter3D:
			var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
			if character.camera == camera:
				character.camera = null
	if controlled_vehicle is ForceDrivenCharacter3D:
		var character: ForceDrivenCharacter3D = controlled_vehicle as ForceDrivenCharacter3D
		character.camera = camera
	else:
		if not _no_cam_warned:
			_no_cam_warned = true
			push_warning(str(controlled_vehicle.get_script().get_global_name(), " camera set is unsupported (only support for ForceDrivenCharacter3D"))

func get_vehicle_type() -> VehicleType:
	if _vehicle is ForceDrivenCharacter3D:
		return VehicleType.FORCE_DRIVEN_CHARACTER
	elif _vehicle is Car:
		return VehicleType.CAR
	elif _vehicle is SpeedBoat:
		return VehicleType.SPEED_BOAT
	elif _vehicle is Helicopter:
		return VehicleType.HELICOPTER
	else:
		return VehicleType.NONE

func _warn_axis(input_axis: InputAxis) -> void:
	if not _axes_warned.has(input_axis):
		_axes_warned.append(input_axis)
		push_warning(str(_vehicle.get_script().get_global_name(), " does not contain input axis ", input_axis))
func _warn_btn(input_btn: InputButton) -> void:
	if not _btns_warned.has(input_btn):
		_btns_warned.append(input_btn)
		push_warning(str(_vehicle.get_script().get_global_name(), " does not contain input button ", input_btn))
static func _draw_exit_spots(parent: Node3D, occupant_info: IOccupy) -> void:
	if occupant_info:
		for exit_spot in occupant_info.exit_spots:
			DebugDraw.draw_cube(parent.to_global(exit_spot), 0.1, Color.RED)
