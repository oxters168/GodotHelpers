extends RigidBody3D
class_name Helicopter

## The highest the helicopter can reach in world space in meters
@export var max_height: float = 50
## The max speed the helicopter can lift itself in meters per second
@export var max_lift_speed: float = 10
## How quickly the helicopter reaches max lift speed in meters per second squared
@export var acceleration: float = 5

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
	if Input.is_action_pressed("move_lat_pos"):
		var global_up: Vector3 = NodeHelpers.get_global_up(self)
		var current_height: float = global_position.y
		var accel_to_max: float = (max_lift_speed - linear_velocity.dot(global_up)) / delta
		var accel: float = min(abs(accel_to_max), acceleration)
		var lift_mag: float = accel * mass
		var lift_force: Vector3 = global_up * lift_mag
		if current_height <= max_height:
			lift_force -= Vector3.UP * lift_force.dot(Vector3.UP)
			var anti_gravity_force: Vector3 = -get_gravity() * mass
			apply_force(anti_gravity_force)
		apply_force(lift_force)
	
	var global_forward: Vector3 = NodeHelpers.get_global_forward(self)
	var flattened_forward: Vector3 = Vector3(global_forward.x, 0, global_forward.z).normalized()
	# var rot_offset: Vector3 = (Basis.looking_at(flattened_forward, Vector3.UP) * global_basis.inverse()).get_euler()
	# var rot_offset: Vector3 = (Basis.looking_at(flattened_forward, Vector3.UP).inverse() * global_basis).get_euler()
	# var rot_offset: Vector3 = (global_basis.inverse() * Basis.looking_at(flattened_forward, Vector3.UP)).get_euler()
	# var rot_offset: Vector3 = (global_basis * Basis.looking_at(flattened_forward, Vector3.UP).inverse()).get_euler()
	var target_quat: Quaternion = Basis.looking_at(flattened_forward, Vector3.UP, true)
	var current_quat: Quaternion = global_basis.get_rotation_quaternion()
	# var offset_quat: Quaternion = target_quat.inverse() * current_quat
	# var offset_quat: Quaternion = target_quat * current_quat.inverse()
	var offset_quat: Quaternion = current_quat.inverse() * target_quat
	# var offset_quat: Quaternion = current_quat * target_quat.inverse()
	var rot_inertia: Vector3 = PhysicsServer3D.body_get_direct_state(self).inverse_inertia.inverse()
	# global_basis = Basis(target_quat)
	_orientation_debug.global_rotation = global_rotation + offset_quat.get_euler()
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_XYZ)
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_XZY)
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_YXZ)
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_YZX)
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_ZXY)
	# _orientation_debug.global_rotation = global_rotation + offset_quat.get_euler(EULER_ORDER_ZYX)
	apply_torque(rot_inertia * ((offset_quat.get_euler() / delta) - angular_velocity))
