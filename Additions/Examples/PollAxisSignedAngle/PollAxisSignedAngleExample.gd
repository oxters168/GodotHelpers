@tool
extends Node3D
class_name PollAxisSignedAngleExample

@export var target: Node3D
@export var axis: Vector3 = Vector3.UP:
	set(value):
		axis = value.normalized()
		_reset_axis_line(100)

var _prev_position: Vector3

var _target_sphere: Node3D = null
var _angle_line: Node3D = null
var _axis_line: Node3D = null

func _ready():
	_reset_axis_line(100)
func _process(_delta):
	if target != null:
		if _axis_line == null:
			_create_axis_line(100)
		if _target_sphere == null:
			_create_target_sphere()
		if !target.global_position.is_equal_approx(_prev_position):
			_prev_position = target.global_position
			_target_sphere.global_position = target.global_position
			_reset_angle_line(target.global_position)

			var dir = target.global_position.normalized()
			var ortho_normals = VectorHelpers.get_ortho_normals(axis)
			# Project vector onto plane
			# var flattened: Vector3 = (dir - (dir.dot(axis) * axis)).normalized()
			var flattened: Vector3 = VectorHelpers.project_on_plane(dir, axis).normalized()
			var angle = ortho_normals.normal_1.signed_angle_to(flattened, axis)
			var quat_angle = QuatHelpers.poll_axis_signed_angle(Quaternion(axis, angle), axis, dir)
			print_debug("signed_angle_to(", rad_to_deg(angle), ") =? poll_axis_signed_angle(", rad_to_deg(quat_angle), ")")
	else:
		_destroy_angle_line()
		_destroy_axis_line()
		_destroy_target_sphere()

func _destroy_target_sphere():
	if _target_sphere != null:
		remove_child(_target_sphere)
		_target_sphere.queue_free()
		_target_sphere = null
func _create_target_sphere():
	_target_sphere = MeshHelpers.create_sphere_3d(0.06, 0.12)
	add_child(_target_sphere)

func _destroy_angle_line():
	if _angle_line != null:
		remove_child(_angle_line)
		_angle_line.queue_free()
		_angle_line = null
func _create_angle_line(vector: Vector3):
	var length: float = vector.length()
	_angle_line = MeshHelpers.create_box_3d(Vector3(min(length * 0.1, 0.02), min(length * 0.1, 0.02), length))
	add_child(_angle_line)
	_angle_line.look_at(vector)
	_angle_line.global_position = vector.normalized() * length / 2
func _reset_angle_line(vector: Vector3):
	_destroy_angle_line()
	_create_angle_line(vector)

func _destroy_axis_line():
	if _axis_line != null:
		remove_child(_axis_line)
		_axis_line.queue_free()
		_axis_line = null
func _create_axis_line(length: float):
	_axis_line = MeshHelpers.create_box_3d(Vector3(min(length * 0.1, 0.02), min(length * 0.1, 0.02), length))
	add_child(_axis_line)
	_axis_line.global_position = Vector3.ZERO
	var ortho_normals = VectorHelpers.get_ortho_normals(axis)
	_axis_line.global_basis = Basis(ortho_normals.normal_1, ortho_normals.normal_2, axis)
func _reset_axis_line(length: float):
	_destroy_axis_line()
	_create_axis_line(length)
	
