extends RigidBody3D
class_name Helicopter

## The highest the helicopter can reach in world space in meters
@export var max_height: float = 50
## The max speed the helicopter can lift itself in meters per second
@export var max_lift_speed: float = 10
## How quickly the helicopter reaches max lift speed in meters per second squared
@export var lift_acceleration: float = 5

## The max speed the helicopter can rotate in radians per second
@export var max_rot_speed: float = PI / 4
## How quickly the helicopter can reach max rotation speed in radians per second squared
@export var rot_acceleration: float = PI / 6

## How far the helicopter can tilt in radians
@export var max_tilt_angle: float = PI / 6
@export var tilt_strength: float = 20
@export var tilt_damp: float = 5

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

func _physics_process(delta: float) -> void:
	var lift_input: float = Input.get_action_strength("look_ver_pos")
	var input_vector: Vector2 = Input.get_vector("move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos")
	var input_rot: float = Input.get_axis("move_lat_neg", "move_lat_pos")

	var global_up: Vector3 = NodeHelpers.get_global_up(self)
	var global_forward: Vector3 = NodeHelpers.get_global_forward(self)
	var global_right: Vector3 = NodeHelpers.get_global_right(self)

	var current_height: float = global_position.y
	if lift_input > 0:
		var lift_accel_to_max: float = max((max_lift_speed - max(linear_velocity.dot(global_up), 0)) / delta, 0)
		var lift_accel: float = min(lift_accel_to_max, lift_acceleration)
		var lift_mag: float = lift_accel * mass
		var lift_force: Vector3 = global_up * lift_mag
		if current_height <= lift_input * max_height:
			var anti_gravity_force: Vector3 = -get_gravity() * mass
			apply_force(anti_gravity_force)
		else:
			lift_force -= Vector3.UP * lift_force.dot(Vector3.UP)
		apply_force(lift_force)
	
	# stabilize helicopter
	var rot_inertia: Vector3 = PhysicsServer3D.body_get_direct_state(self).inverse_inertia.inverse()

	var flattened_forward: Vector3 = Vector3(global_forward.x, 0, global_forward.z).normalized()
	var target_basis: Basis = Basis.looking_at(flattened_forward, Vector3.UP, true)
	var input_tilt_percent: float = input_vector.length()
	# var input_tilt_angle: float = 0
	if input_tilt_percent > 0:
		var input_tilt_dir: Vector3 = global_basis * Vector3(input_vector.x, 0, -input_vector.y).normalized()
		DebugDraw.draw_ray_3d(global_position, input_tilt_dir, 2, Color.BLUE)
		var input_tilt_axis: Vector3 = input_tilt_dir.cross(global_up)
		# DebugDraw.draw_ray_3d(global_position, input_tilt_axis, 2, Color.RED)
		# input_tilt_angle = global_rotation.dot(input_tilt_axis)
		target_basis = target_basis.rotated(input_tilt_axis, -max_tilt_angle * input_tilt_percent)
	var tilt_basis: Basis = target_basis * global_basis.inverse()
	# var tilt_basis: Basis = global_basis.inverse() * target_basis
	# var tilt_offset: Vector3 = tilt_basis.get_euler()
	# var tilt_velocity: Vector3 = tilt_offset / delta
	var tilt_quat: Quaternion = Quaternion(tilt_basis)
	var flip_axis: bool = tilt_quat.w < 0 # for a consistent axis
	var tilt_axis: Vector3 = tilt_quat.get_axis() * (-1 if flip_axis else 1)
	var tilt_angle_offset: float = tilt_quat.get_angle() * (-1 if flip_axis else 1)
	if abs(tilt_angle_offset) > Constants.EPSILON:
		DebugDraw.draw_ray_3d(global_position, tilt_axis, 2, Color.RED)
		var angular_velocity_in_tilt: float = angular_velocity.dot(tilt_axis)
		var tilt_accel: float = (tilt_angle_offset * tilt_strength) - (angular_velocity_in_tilt * tilt_damp)
		# var tilt_torque: Vector3 = global_basis * (rot_inertia * (global_basis.inverse() * (tilt_axis * tilt_accel)))
		var tilt_torque: Vector3 = rot_inertia.length() * (tilt_axis * tilt_accel)
		# var tilt_torque: Vector3 = rot_inertia * (tilt_axis * tilt_accel)
		# var tilt_torque: Vector3 = tilt_axis * tilt_accel
		_orientation_debug.global_basis = target_basis
		# _orientation_debug.global_rotation = global_rotation + tilt_offset
		DebugDraw.set_text(str(self), str("tilt_angle_offset: ", MathHelpers.print_format(tilt_angle_offset), " tilt_accel: ", MathHelpers.print_format(tilt_accel), " tilt_torque: ", MathHelpers.print_format(tilt_torque), " inertia: ", rot_inertia))
		apply_torque(tilt_torque)

	var up_rot_velocity: float = angular_velocity.dot(global_up)
	var rot_accel_to_max: float = max((abs(input_rot * max_rot_speed) - abs(up_rot_velocity)) / delta, 0)
	var rot_accel: float = sign(input_rot) * min(abs(rot_accel_to_max), rot_acceleration)
	var rot_torque: Vector3 = global_basis * (rot_inertia * (global_basis.inverse() * (global_up * -rot_accel)))
	apply_torque(rot_torque) # not fully reaching max rotation speed, I think due to the stabilizing torque applied later

	var current_lift_speed: float = linear_velocity.dot(global_up)
	# DebugDraw.set_text(str(self), str("height: ", MathHelpers.to_decimal_places(current_height, 2), " lift_speed: ", MathHelpers.print_format(current_lift_speed), " rot_speed: ", MathHelpers.print_format(up_rot_velocity), " tilt_angle_offset: ", MathHelpers.print_format(tilt_angle_offset), " tilt_accel: ", MathHelpers.print_format(tilt_accel)))
