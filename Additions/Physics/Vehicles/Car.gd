extends RigidBody3D
class_name Car

@export var wheels: Array[Wheel3D]

## The maximum speed the car can travel in meters per second
@export var max_speed: float = 20
## The acceleration of the car in meters per second squared
@export var acceleration: float = 10
## The deceleration of the car in meters per second squared
@export var deceleration: float = 0.04
## How much percent acceleration the wheel should have, represented by the y-axis, in relation to
## the percent max velocity it currently has, represented by the x-axis
@export var accel_curve: Curve

@export var debug: bool = false

func _ready() -> void:
  if wheels:
    for wheel in wheels:
      wheel.add_exception(get_rid())

func _physics_process(delta: float) -> void:
  var input_vector: Vector2 = Vector2(Input.get_axis("move_hor_neg", "move_hor_pos"), Input.get_axis("move_ver_neg", "move_ver_pos"))
  var velocity: float = NodeHelpers.get_global_forward(self).dot(linear_velocity)
  if debug:
    DebugDraw.set_text(str(self), str("velocity: ", velocity))
  if wheels:
    for wheel in wheels:
      wheel.debug = debug
      var force: Vector3 = wheel.calculate_force_on_vehicle(self, input_vector, delta)
      apply_force(force, wheel.global_position - global_position)

func get_wheel_count() -> int:
  return wheels.size() if wheels else 0