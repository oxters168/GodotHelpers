extends RigidBody3D
class_name Helicopter

## The highest the helicopter can reach in world space in meters
@export var max_height: float = 20
## The max speed the helicopter can lift itself in meters per second
@export var max_lift_speed: float = 10
## How quickly the helicopter reaches max lift speed in meters per second squared
@export var lift_acceleration: float = 5

## The max speed the helicopter can rotate in radians per second
@export var max_rot_speed: float = PI / 2
## How quickly the helicopter can reach max rotation speed in radians per second squared
@export var rot_acceleration: float = PI / 2
## How quickly the the helicopter rotation comes to a halt when no there is no input in radians per second squared
@export var rot_deceleration: float = PI / 2

## How far the helicopter can tilt in radians
@export var max_tilt_angle: float = PI / 6
## The strength of the helicopter tilts with
@export var tilt_strength: float = 5
## The damping applied to the current tilt velocity
@export var tilt_damp: float = 3

## How many milliseconds it takes for the helicopter blades to be fully spinning and ready to lift
@export var time_to_power: int = 3000
## The node to be spun for the top blades as the helicopter lift is applied
@export var top_blades: Node3D
## The node to be spun for the tail blades as the helicopter rotates
@export var tail_blades: Node3D

## Info on occupying and being occupied
@export var occupant_info: IOccupy = preload("res://godot_helpers/Additions/Physics/Vehicles/Extras/non_occupier_with_2_seats.tres")

## Show debug info
@export var debug: bool

## A [float] value clamped between 0 and 1 that represents how much force to be applied to lift the helicopter
var input_lift: float = 0:
	set(value):
		input_lift = clampf(value, 0, 1)
## A [Vector2] that is normalized and represents how much to rotate along the pitch and roll axes
var input_tilt_vector: Vector2 = Vector2.ZERO:
	set(value):
		input_tilt_vector = value.normalized()
## A [float] value clamped between -1 and 1 that represents how much to rotate along the yaw axis
var input_rot: float = 0:
	set(value):
		input_rot = clampf(value, -1, 1)

var _power: float = 0
var _orientation_debug: Node3D

func _init() -> void:
	var prism_shape: PrismMesh = PrismMesh.new()
	prism_shape.size = Vector3(0.4, 0.4, 0.1)
	var prism: MeshInstance3D = MeshInstance3D.new()
	prism.mesh = prism_shape
	prism.rotation = Vector3(-PI / 2, 0, 0)
	_orientation_debug = Node3D.new()
	_orientation_debug.add_child(prism)
	add_child(_orientation_debug)
func _ready() -> void:
	add_child(Vehicle.new(self))

func _physics_process(delta: float) -> void:
	# var input_lift: float = Input.get_action_strength("look_ver_pos")
	# var input_tilt_vector: Vector2 = Input.get_vector("move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos")
	# var input_rot: float = Input.get_axis("move_lat_neg", "move_lat_pos")

	var global_up: Vector3 = NodeHelpers.get_global_up(self)
	var current_lift_speed: float = linear_velocity.dot(global_up)
	var is_moving_vertically: bool = abs(linear_velocity.y) > 0.1
	
	var power_offset: float = (delta * 1000) / time_to_power
	if input_lift > Constants.EPSILON:
		_power += power_offset
	elif not is_moving_vertically:
		_power -= power_offset
	_power = MathHelpers.to_decimal_places(clampf(_power, 0, 1), 3)
	if top_blades:
		top_blades.rotate(Vector3.UP, _power * -(PI / 6))
	if tail_blades:
		tail_blades.rotate(Vector3.RIGHT, _power * (PI / 6))

	var current_height: float = global_position.y
	var tilt_angle_offset: float = 0
	var up_rot_velocity: float = angular_velocity.dot(global_up)

	# if fully powered up or falling
	if _power >= 1 or is_moving_vertically:
		var global_forward: Vector3 = NodeHelpers.get_global_forward(self)

		if input_lift > 0:
			var lift_accel_to_max: float = max((max_lift_speed - max(linear_velocity.dot(global_up), 0)) / delta, 0)
			var lift_accel: float = min(lift_accel_to_max, lift_acceleration)
			var lift_mag: float = lift_accel * mass
			var lift_force: Vector3 = _power * global_up * lift_mag
			if current_height <= input_lift * max_height:
				var anti_gravity_force: Vector3 = _power * -get_gravity() * mass
				apply_force(anti_gravity_force)
			else:
				lift_force -= Vector3.UP * lift_force.dot(Vector3.UP)
			apply_force(lift_force)
		
		# stabilize helicopter
		var rot_inertia: Vector3 = PhysicsServer3D.body_get_direct_state(self).inverse_inertia.inverse()

		var flattened_forward: Vector3 = Vector3(global_forward.x, 0, global_forward.z).normalized()
		var target_basis: Basis = Basis.looking_at(flattened_forward, Vector3.UP, true)
		var input_tilt_percent: float = input_tilt_vector.length()
		if input_tilt_percent > 0:
			var input_tilt_dir: Vector3 = global_basis * Vector3(-input_tilt_vector.x, 0, input_tilt_vector.y).normalized()
			if debug:
				DebugDraw.draw_ray_3d(global_position, input_tilt_dir, 2, Color.BLUE)
			var input_tilt_axis: Vector3 = input_tilt_dir.cross(global_up)
			target_basis = target_basis.rotated(input_tilt_axis, -max_tilt_angle * input_tilt_percent)
		var tilt_diff_basis: Basis = target_basis * global_basis.inverse()
		var tilt_quat: Quaternion = tilt_diff_basis.get_rotation_quaternion()
		var flip_axis: bool = tilt_quat.w < 0 # for a consistent axis
		var tilt_axis: Vector3 = tilt_quat.get_axis() * (-1 if flip_axis else 1)
		tilt_angle_offset = tilt_quat.get_angle() * (-1 if flip_axis else 1)
		if abs(tilt_angle_offset) > Constants.EPSILON:
			if debug:
				DebugDraw.draw_ray_3d(global_position, tilt_axis, 2, Color.RED)
			var angular_velocity_in_tilt: float = angular_velocity.dot(tilt_axis)
			var tilt_accel: float = (tilt_angle_offset * tilt_strength) - (angular_velocity_in_tilt * tilt_damp)
			var tilt_torque: Vector3 = _power * rot_inertia.length() * (tilt_axis * tilt_accel)
			tilt_torque -= global_up * tilt_torque.dot(global_up)
			_orientation_debug.global_basis = target_basis
			apply_torque(tilt_torque)

		if abs(input_rot) > Constants.EPSILON:
			var rot_accel_to_max: float = max((abs(input_rot * max_rot_speed) - abs(up_rot_velocity)) / delta, 0)
			var rot_accel: float = _power * sign(input_rot) * min(abs(rot_accel_to_max), rot_acceleration)
			var rot_torque: Vector3 = global_basis * (rot_inertia * (global_basis.inverse() * (global_up * -rot_accel)))
			apply_torque(rot_torque)
		else:
			var rot_accel_to_halt: float = -up_rot_velocity
			var rot_accel: float = _power * sign(rot_accel_to_halt) * min(abs(rot_accel_to_halt), rot_deceleration)
			var rot_torque: Vector3 = global_basis * (rot_inertia * (global_basis.inverse() * (global_up * rot_accel)))
			apply_torque(rot_torque)

	_orientation_debug.visible = debug
	if debug:
		DebugDraw.set_text(str(self), str("power: ", _power, " height: ", MathHelpers.to_decimal_places(current_height, 2), " lift_speed: ", MathHelpers.print_format(current_lift_speed), " rot_speed: ", MathHelpers.print_format(up_rot_velocity), " tilt_angle_offset: ", MathHelpers.print_format(tilt_angle_offset)))
