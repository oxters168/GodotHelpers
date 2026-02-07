@tool
extends RigidBody3D
class_name ForceDrivenCharacter3D

## The max speed of the character in meters per second
@export var max_speed: float = 5
## How quickly the character reaches max speed in meters per second squared
@export var acceleration: float = 5
## How quickly the character slows down to a halt in meters per second squared
@export var deceleration: float = 5

func _init() -> void:
  if Engine.is_editor_hint():
    self.lock_rotation = true

func _physics_process(delta: float) -> void:
  if not Engine.is_editor_hint():
    var input_vector: Vector2 = Input.get_vector("move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos")
    var move_direction: Vector3 = global_basis * Vector3(-input_vector.x, 0, input_vector.y)

    var move_percent: float = input_vector.length()
    DebugDraw.set_text(str(self), str("velocity: ", linear_velocity))
    if move_percent > Constants.EPSILON:
      var current_velocity: float = move_direction.dot(linear_velocity)
      var extraneous_velocity: Vector3 = linear_velocity - (move_direction * current_velocity)
      var stop_force: Vector3 = _force_to_decel_velocity(extraneous_velocity, deceleration, mass, delta)
      DebugDraw.draw_ray_3d(global_position + NodeHelpers.get_global_up(self), stop_force.normalized(), (stop_force.length() / (deceleration * mass)) * 2, Color.RED)
      apply_force(stop_force)

      var accel_to_max: float = (max_speed - current_velocity) / delta
      var accel: float = min(abs(accel_to_max), acceleration)
      var move_mag: float = move_percent * accel * mass
      var move_force: Vector3 = move_direction * move_mag
      DebugDraw.draw_ray_3d(global_position + NodeHelpers.get_global_up(self), move_direction, (move_mag / (acceleration * mass)) * 2, Color.BLUE)
      apply_force(move_force)
    else:
      var stop_force: Vector3 = _force_to_decel_velocity(linear_velocity, deceleration, mass, delta)
      DebugDraw.draw_ray_3d(global_position + NodeHelpers.get_global_up(self), stop_force.normalized(), (stop_force.length() / (deceleration * mass)) * 2, Color.RED)
      apply_force(stop_force)

static func _force_to_decel_velocity(velocity: Vector3, deceleration: float, mass: float, delta: float) -> Vector3:
  var decel_to_halt: float = velocity.length() / delta
  var decel: float = min(decel_to_halt, deceleration)
  var stop_mag: float = decel * mass
  return -velocity.normalized() * stop_mag