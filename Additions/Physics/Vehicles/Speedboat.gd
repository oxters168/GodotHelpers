extends RigidBody3D
class_name SpeedBoat

## The rate at which the boat accelerates in meters per second per second
@export var acceleration: float = 12
## The max speed the boat can reach in meters per second
@export var max_speed: float = 30

## The rate at which the boat roatationally accelerates in radians per second per second
@export var turn_acceleration: float = PI
## The max turn speed of the boat in radians per second
@export var max_turn_speed: float = 2 * PI

## Show debug data
@export var debug: bool = false

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2(Input.get_axis("move_hor_neg", "move_hor_pos"), Input.get_axis("move_ver_neg", "move_ver_pos"))
	var direct_state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(get_rid())
	
	var global_forward: Vector3 = NodeHelpers.get_global_forward(self)
	var current_velocity: float = linear_velocity.dot(global_forward)
	var pre_damp_accel: float = input_vector.y * acceleration
	var total_linear_damp: float = direct_state.total_linear_damp
	var cancel_damp_accel: float = abs(total_linear_damp * (current_velocity + pre_damp_accel * delta))
	var input_accel: float = input_vector.y * (acceleration + cancel_damp_accel)
	var projected_velocity: float = current_velocity + input_accel * delta
	if abs(projected_velocity) > max_speed:
		input_accel = sign(input_accel) * ((max_speed - abs(current_velocity)) + cancel_damp_accel)
	var forward_force: Vector3 = global_forward * mass * input_accel
	apply_force(forward_force)

	var physics_server_inertia: Vector3 = direct_state.inverse_inertia.inverse()
	var global_up: Vector3 = NodeHelpers.get_global_up(self)
	var current_angular_velocity: float = angular_velocity.dot(global_up)
	var pre_damp_angular_accel: float = input_vector.x * -turn_acceleration
	var total_angular_damp: float = direct_state.total_angular_damp
	var angular_cancel_damp: float = abs(total_angular_damp * (current_angular_velocity + pre_damp_angular_accel * delta))
	var input_angular_accel: float = (input_vector.x * -(turn_acceleration + angular_cancel_damp))
	var projected_angular_velocity: float = current_angular_velocity + input_angular_accel * delta
	if abs(projected_angular_velocity) > max_turn_speed:
		input_angular_accel = sign(input_angular_accel) * ((max_turn_speed - abs(current_angular_velocity)) + angular_cancel_damp)
	var torque: Vector3 = global_basis * (physics_server_inertia.y * (global_basis.inverse() * (global_up * input_angular_accel)))
	apply_torque(torque)

	if debug:
		DebugDraw.set_text(str(self), str("velocity: ", current_velocity, " angular_velocity: ", current_angular_velocity))

