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
}

var _vehicle: Variant

func _init(vehicle: Variant) -> void:
  _vehicle = vehicle

func set_input_axis(input_axis: InputAxis, value: float) -> void:
  if _vehicle is Car:
    var car: Car = _vehicle as Car
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        car.input_vector = Vector2(car.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        car.input_vector = Vector2(value, car.input_vector.y)
  elif _vehicle is SpeedBoat:
    var speedboat: SpeedBoat = _vehicle as SpeedBoat
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        speedboat.input_vector = Vector2(speedboat.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        speedboat.input_vector = Vector2(value, speedboat.input_vector.y)
  elif _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    match input_axis:
      InputAxis.VERTICAL_AXIS:
        character.input_vector = Vector2(character.input_vector.x, value)
      InputAxis.HORIZONTAL_AXIS:
        character.input_vector = Vector2(value, character.input_vector.y)
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
  # else:
  #   printerr(str(_vehicle.get_script().get_global_name(), " axis input is unsupported (only support for Car, ForceDrivenCharacter3D, Helicopter, and SpeedBoat"))

func set_input_button(input_btn: InputButton, value: bool) -> void:
  if _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    match input_btn:
      InputButton.JUMP_BTN:
        character.jump_btn = value
  # else:
  #   printerr(str(_vehicle.get_script().get_global_name(), " button input is unsupported (only support for ForceDrivenCharacter3D"))

func set_camera(camera: Node3D) -> void:
  if _vehicle is ForceDrivenCharacter3D:
    var character: ForceDrivenCharacter3D = _vehicle as ForceDrivenCharacter3D
    character.camera = camera