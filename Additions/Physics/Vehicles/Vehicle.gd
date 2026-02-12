extends Node3D
## This class is not meant to be used directly but is automatically created
## by vehicles as a child
class_name Vehicle

enum InputAxis {
  VERTICAL_AXIS,   ## Normally gas/brake or forward/backward
  HORIZONTAL_AXIS, ## Normally left/right
  YAW_AXIS,        ## Currently only used with [Helicopter]
  PITCH_AXIS,      ## Currently only used with [Helicopter]
  LIFT_AXIS,       ## Currently only used with [Helicopter]
}
enum InputButton {
  JUMP_BTN, ## Currently only used with [ForceDrivenCharacter3D]
  OCCUPY_BTN, ## For entering/exiting vehicles
}

var _vehicle: Variant

var _occupying: Vehicle
var _occupied_seats: Array[Vehicle] = []

var _axes_warned: Array[InputAxis] = []
var _btns_warned: Array[InputButton] = []
var _no_vehicle_axis_warned: bool
var _no_vehicle_btn_warned: bool
var _no_cam_warned: bool

func _init(vehicle: Variant) -> void:
  _vehicle = vehicle

func add_occupant(occupant: Vehicle) -> bool:
  if _occupied_seats.size() < _vehicle.occupant_info.occupant_seats:
    occupant.occupying = self
    _occupied_seats.append(occupant)
    return true
  else:
    return false
func remove_occupant(occupant: Vehicle) -> bool:
  if _occupied_seats.has(occupant):
    occupant._occupying = null
    _occupied_seats.erase(occupant)
    return true
  else:
    return false
func has_occupant(occupant: Vehicle) -> bool:
  return _occupied_seats.has(occupant)

func set_input_axis(input_axis: InputAxis, value: float) -> void:
  if _vehicle is Car:
    var car: Car = _vehicle as Car
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        car.input_vector = Vector2(car.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        car.input_vector = Vector2(value, car.input_vector.y)
      _: _warn_axis(input_axis)
  elif _vehicle is SpeedBoat:
    var speedboat: SpeedBoat = _vehicle as SpeedBoat
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        speedboat.input_vector = Vector2(speedboat.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        speedboat.input_vector = Vector2(value, speedboat.input_vector.y)
      _: _warn_axis(input_axis)
  elif _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        character.input_vector = Vector2(character.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        character.input_vector = Vector2(value, character.input_vector.y)
      _: _warn_axis(input_axis)
  elif _vehicle is Helicopter:
    var helicopter: Helicopter = _vehicle as Helicopter
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
  if input_btn == InputButton.OCCUPY_BTN and value:
    var bounds: AABB = NodeHelpers.get_total_bounds_3d(_vehicle, true, true)
    # DebugDraw.draw_box(_vehicle.to_global(bounds.position + bounds.size / 2), bounds.size, Color.BLUE)
    DebugDraw.draw_box_aabb(bounds, Color.BLUE)
  if _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    match input_btn:
      InputButton.JUMP_BTN:
        character.jump_btn = value
      InputButton.OCCUPY_BTN:
        if value:
          var bounds: AABB = NodeHelpers.get_total_bounds_3d(_vehicle, true, true)
          # DebugDraw.draw_box(_vehicle.to_global(bounds.position + bounds.size / 2), bounds.size, Color.BLUE)
          DebugDraw.draw_box_aabb(bounds, Color.BLUE)
      _: _warn_btn(input_btn)
  else:
    if not _no_vehicle_btn_warned:
      _no_vehicle_btn_warned = true
      push_warning(str(_vehicle.get_script().get_global_name(), " button input is unsupported (only support for ForceDrivenCharacter3D"))

func set_camera(camera: Node3D) -> void:
  if _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    character.camera = camera
  else:
    if not _no_cam_warned:
      _no_cam_warned = true
      push_warning(str(_vehicle.get_script().get_global_name(), " camera set is unsupported (only support for ForceDrivenCharacter3D"))

func _warn_axis(input_axis: InputAxis) -> void:
  if not _axes_warned.has(input_axis):
    _axes_warned.append(input_axis)
    push_warning(str(_vehicle.get_script().get_global_name(), " does not contain input axis ", input_axis))
func _warn_btn(input_btn: InputButton) -> void:
  if not _btns_warned.has(input_btn):
    _btns_warned.append(input_btn)
    push_warning(str(_vehicle.get_script().get_global_name(), " does not contain input button ", input_btn))