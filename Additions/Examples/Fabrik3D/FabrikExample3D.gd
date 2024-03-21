@tool
extends Node3D
class_name FabrikExample3D

@export var target: Node3D
@export var max_iterations: int = 16
@export var distance_error_margin: float = 0.01
@export var segment_count: int = 3:
	set(value):
		segment_count = max(value, 1)
		_reset_segments()
		_refresh_constraints()
		notify_property_list_changed()
@export var segment_length: float = 1:
	set(value):
		segment_length = max(value, 0.01)
		_reset_segments()
@export var constrained: bool = false:
	set(value):
		constrained = value
		notify_property_list_changed()
@export var use_target_rot: bool = false

var _constraints: Array[AngularLimits3D]
var _segments: Array[Node3D] = []
var _target_sphere: Node3D = null
var _prev_target_pos: Vector3
var _prev_target_rot: Basis

func _get_property_list():
	var property_list: Array = []
	if constrained:
		property_list.append({
			name = "Constraints",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY
		})
		for i in _constraints.size():
			property_list.append({
				name = str("Segment ", i),
				type = TYPE_NIL,
				usage = PROPERTY_USAGE_SUBGROUP
			})
			property_list.append({
				name = _get_lower_limit_name(i),
				type = TYPE_VECTOR3,
				usage = PROPERTY_USAGE_DEFAULT
			})
			property_list.append({
				name = _get_upper_limit_name(i),
				type = TYPE_VECTOR3,
				usage = PROPERTY_USAGE_DEFAULT
			})
	return property_list
func _get(property: StringName):
	for i in _constraints.size():
		if property == _get_lower_limit_name(i):
			return Vector3(rad_to_deg(_constraints[i].lower_limit.x), rad_to_deg(_constraints[i].lower_limit.y), rad_to_deg(_constraints[i].lower_limit.z))
		if property == _get_upper_limit_name(i):
			return Vector3(rad_to_deg(_constraints[i].upper_limit.x), rad_to_deg(_constraints[i].upper_limit.y), rad_to_deg(_constraints[i].upper_limit.z))
func _set(property: StringName, value: Variant):
	for i in _constraints.size():
		if property == _get_lower_limit_name(i):
			_constraints[i].lower_limit = Vector3(wrapf(deg_to_rad(value.x), -PI, _constraints[i].upper_limit.x + 0.0001), wrapf(deg_to_rad(value.y), -PI, _constraints[i].upper_limit.y + 0.0001), wrapf(deg_to_rad(value.z), -PI, _constraints[i].upper_limit.z + 0.0001))
		if property == _get_upper_limit_name(i):
			_constraints[i].upper_limit = Vector3(wrapf(deg_to_rad(value.x), _constraints[i].lower_limit.x, PI + 0.0001), wrapf(deg_to_rad(value.y), _constraints[i].lower_limit.y, PI + 0.0001), wrapf(deg_to_rad(value.z), _constraints[i].lower_limit.z, PI + 0.0001))
func _property_get_revert(property: StringName):
	for i in _constraints.size():
		if property == _get_lower_limit_name(i):
			return Vector3.ONE * -180
		if property == _get_upper_limit_name(i):
			return Vector3.ONE * 180
func _property_can_revert(property: StringName):
	for i in _constraints.size():
		if property == _get_lower_limit_name(i):
			return true
		if property == _get_upper_limit_name(i):
			return true

func _init():
	_refresh_constraints()
func _process(_delta):
	if target != null:
		if _segments.size() != segment_count:
			_reset_segments()
		if _target_sphere == null:
			_create_target_sphere()
		
		if !_prev_target_pos.is_equal_approx(target.global_position) || !_prev_target_rot.is_equal_approx(target.global_basis):
			_prev_target_pos = target.global_position
			_prev_target_rot = target.global_basis
			_target_sphere.global_position = target.global_position

			var segment_transforms: Array[Transform3D] = []
			segment_transforms.resize(segment_count)
			var segment_lengths: Array[float] = []
			segment_lengths.resize(segment_count)
			for i in segment_count:
				segment_transforms[i] = Transform3D(_segments[i].global_basis, _segments[i].global_position - NodeHelpers.get_global_forward(_segments[i]) * (segment_length / 2))
				segment_lengths[i] = segment_length
			var result_transforms: Array[Transform3D]
			if constrained:
				result_transforms = SkeletonHelpers.fabrik_solve_3d(global_position, target.global_transform, segment_transforms, segment_lengths, use_target_rot, max_iterations, distance_error_margin, _constraints)
			else:
				result_transforms = SkeletonHelpers.fabrik_solve_3d(global_position, target.global_transform, segment_transforms, segment_lengths, use_target_rot, max_iterations, distance_error_margin)
			
			for i in _segments.size():
				_segments[i].global_position = result_transforms[i].origin + BasisHelpers.get_forward(result_transforms[i].basis) * (segment_length / 2)
				_segments[i].global_basis = result_transforms[i].basis

				var current_basis: Basis = _segments[i].basis
				if i > 0:
					current_basis = BasisHelpers.to_local(_segments[i - 1].basis, current_basis)
				var euler_raw: Vector3 = current_basis.get_euler()
				var euler: Vector3 = Vector3(rad_to_deg(euler_raw.x), rad_to_deg(euler_raw.y), rad_to_deg(euler_raw.z))
				# print_debug("Segment[", i, "]: ", euler)
				if !Engine.is_editor_hint():
					DebugDraw.set_text(str(i), euler)
					DebugDraw.draw_axes(result_transforms[i], 0.2)
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

func _get_lower_limit_name(index: int) -> String:
	return str("segment_", index, "_lower_limit")
func _get_upper_limit_name(index: int) -> String:
	return str("segment_", index, "_upper_limit")
func _refresh_constraints():
	if _constraints == null || _constraints.size() != segment_count:
		var old_constraints = _constraints
		_constraints = []
		_constraints.resize(segment_count)
		for i in segment_count:
			if old_constraints != null && i < old_constraints.size():
				_constraints[i] = old_constraints[i]
			else:
				_constraints[i] = AngularLimits3D.new(Vector3.ONE * -PI, Vector3.ONE * PI)
