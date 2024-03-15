@tool
extends Node3D
class_name FabrikExample3D

@export var target: Node3D
@export var max_iterations: int = 16
@export var distance_error_margin: float = 0.01
@export var segment_count: int = 3:
	set(value):
		segment_count = value
		_reset_segments()
@export var segment_length: float = 1:
	set(value):
		segment_length = value
		_reset_segments()

var _segments: Array[Node3D] = []
var _target_sphere: Node3D = null

func _process(_delta):
	if target != null:
		if _segments.size() != segment_count:
			_reset_segments()
		if _target_sphere == null:
			_create_target_sphere()
		_target_sphere.global_position = target.global_position

		var segment_transforms: Array[Transform3D] = []
		segment_transforms.resize(segment_count)
		var segment_lengths: Array[float] = []
		segment_lengths.resize(segment_count)
		var segment_constraints: Array[SkeletonHelpers.FabrikConstraint3D] = []
		segment_constraints.resize(segment_count)
		for i in segment_count:
			segment_transforms[i] = Transform3D(_segments[i].global_basis, _segments[i].global_position - NodeHelpers.get_global_forward(_segments[i]) * (segment_length / 2))
			segment_lengths[i] = segment_length
			segment_constraints[i] = SkeletonHelpers.FabrikConstraint3D.new(Vector3(deg_to_rad(-45), deg_to_rad(-30), deg_to_rad(-15)), Vector3(deg_to_rad(45), deg_to_rad(30), deg_to_rad(15)))
			# segment_constraints[i] = SkeletonHelpers.FabrikConstraint3D.new(Vector3(deg_to_rad(-180), deg_to_rad(-180), deg_to_rad(-180)), Vector3(deg_to_rad(180), deg_to_rad(180), deg_to_rad(180)))
		var result_transforms = SkeletonHelpers.fabrik_solve_3d(global_position, target.global_position, segment_transforms, segment_lengths, max_iterations, distance_error_margin, segment_constraints)
		
		for i in _segments.size():
			_segments[i].global_basis = result_transforms[i].basis
			_segments[i].global_position = result_transforms[i].origin + NodeHelpers.get_global_forward(_segments[i]) * (segment_length / 2)
			if !Engine.is_editor_hint():
				var euler_raw: Vector3 = _segments[i].basis.get_euler()
				var euler: Vector3 = Vector3(rad_to_deg(euler_raw.x), rad_to_deg(euler_raw.y), rad_to_deg(euler_raw.z))
				DebugDraw.set_text(str(i), euler)
	else:
		_destroy_segments()
		_destroy_target_sphere()

func _destroy_segments():
	for segment in _segments:
		remove_child(segment)
		segment.queue_free()
	_segments.clear()
func _create_segments():
	for i in segment_count:
		var box = MeshHelpers.create_box_3d(Vector3(segment_length * 0.1, segment_length * 0.1, segment_length))
		add_child(box)
		_segments.append(box)
func _reset_segments():
	_destroy_segments()
	_create_segments()

func _destroy_target_sphere():
	if _target_sphere != null:
			remove_child(_target_sphere)
			_target_sphere.queue_free()
func _create_target_sphere():
	_target_sphere = MeshHelpers.create_sphere_3d(0.06, 0.12)
	add_child(_target_sphere)
