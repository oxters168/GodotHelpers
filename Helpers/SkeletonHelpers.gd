class_name SkeletonHelpers

## Sets the skeleton bone's rotation to the given world space orientation
## Source: https://www.reddit.com/r/godot/comments/17bhmaw/comment/k5mn6bm/?utm_source=share&utm_medium=web2x&context=3
static func set_bone3d_global_rotation(skeleton: Skeleton3D, bone_id: int, global_rotation: Quaternion):
	var bone_local_rot: Quaternion = skeleton.get_bone_rest(bone_id).basis.get_rotation_quaternion()
	var parent_bone_skel_rot: Quaternion = Quaternion.IDENTITY
	var parent_bone_id: int = skeleton.get_bone_parent(bone_id)
	if parent_bone_id > -1:
		parent_bone_skel_rot = skeleton.get_bone_global_pose(parent_bone_id).basis.get_rotation_quaternion()
	var skeleton_global_rot: Quaternion = skeleton.global_transform.basis.get_rotation_quaternion()
	var parent_bone_global_rot: Quaternion = QuatHelpers.to_global(skeleton_global_rot, parent_bone_skel_rot)
	var bone_global_rotation: Quaternion = QuatHelpers.to_global(parent_bone_global_rot, bone_local_rot)
	var new_bone_global_rotation: Quaternion = global_rotation * bone_global_rotation
	var bone_pose_rotation = QuatHelpers.to_local(parent_bone_global_rot, new_bone_global_rotation)
	skeleton.set_bone_pose_rotation(bone_id, bone_pose_rotation)

	# DebugDraw.draw_axes(Transform3D(Basis(bone_global_rotation), skeleton.to_global(skeleton.get_bone_global_pose(bone_id).origin)), 0.3)
	# DebugDraw.draw_axes(Transform3D(Basis(bone_local_rot), skeleton.to_global(skeleton.get_bone_global_pose(bone_id).origin)), 0.3)

## Angular constraint data for fabrik solver
class FabrikConstraint3D:
	var lower_limit: Vector3
	var upper_limit: Vector3
	func _init(lower_limit_: Vector3, upper_limit_: Vector3):
		lower_limit = lower_limit_
		upper_limit = upper_limit_
## Calculates the directions needed to set up the given segments to reach towards the [param target_point] from the [param base_point] using forwards and backwards reaching inverse kinematics.
## [param segment_positions] is the array containing the current base positions of the segments. The output array contains direction vectors for how to orient the segments. The first
## value in this array represents the direction of the first segment starting from the [param base_point], the second direction would be the orientation of the next segment whose base position
## would be at the end of the first segment, and so on. The [param segment_lengths] array contains the length of each segment where the [param segment_positions] array values make up the base
## of each segment. This means that [param segment_lengths] will always be the same size as [param segment_positions]. [param distance_margin_error] is how far the minimum distance the
## last joint needs to reach from [param target_point] to be considered a successful fabrik solution and end the solve loop. [param max_iterations] is the maximum amount of times to run
## the fabrik solver before [param distance_margin_error] is reached.
static func fabrik_solve_3d(
	base_point: Vector3,
	target_point: Vector3,
	segment_transforms: Array[Transform3D],
	segment_lengths: Array[float],
	max_iterations: int = 16,
	distance_margin_error: float = 0.01,
	angle_constraints: Array[FabrikConstraint3D] = []
) -> Array[Transform3D]:
	assert(segment_lengths.size() == segment_transforms.size(), "FABRIK solver received incorrect amount of segment lengths")
	assert(angle_constraints.size() == 0 || angle_constraints.size() == segment_transforms.size(), "FABRIK solver received incorrect amount of angle constraints")

	# var result_dirs: Array[Vector3] = []
	# result_dirs.resize(segment_lengths.size())
	var current_transforms: Array[Transform3D] = []
	for segment_transform in segment_transforms:
		current_transforms.append(Transform3D(segment_transform))

	var total_reach_length: float = segment_lengths.reduce(func(accum, length): return accum + length)
	var target_base_diff: Vector3 = target_point - base_point
	# if there are no angular constraints and target is too far to reach then set resulting positions to be in a straight line to the target
	if angle_constraints.size() <= 0 && (total_reach_length * total_reach_length) < target_base_diff.length_squared():
		var target_base_dir: Vector3 = target_base_diff.normalized()
		var ortho_normals: Dictionary = VectorHelpers.get_ortho_normals(target_base_dir)
		var straight_basis: Basis = Basis(ortho_normals.normal_1, ortho_normals.normal_2, target_base_dir)
		current_transforms[0].basis = straight_basis
		current_transforms[0].origin = base_point
		for i in range(1, segment_transforms.size()):
			current_transforms[i].basis = straight_basis
			current_transforms[i].origin = current_transforms[i - 1].origin + target_base_dir * segment_lengths[i - 1]
	else:
		# append an extra point to represent the target
		current_transforms.append(Transform3D(Basis(), target_point))

		var sqr_dist_margin: float = distance_margin_error * distance_margin_error
		var current_sqr_distance: float = Constants.FLOAT_MAX
		var current_iteration: int = 0
		while current_sqr_distance > sqr_dist_margin && current_iteration < max_iterations:
			# backwards pass
			current_transforms[current_transforms.size() - 1].origin = target_point
			for i in range(current_transforms.size() - 1, 0, -1):
				var joint_a: Vector3 = current_transforms[i].origin
				var joint_b: Vector3 = current_transforms[i - 1].origin
				var dir = (joint_b - joint_a).normalized()
				var ortho_normals: Dictionary = VectorHelpers.get_ortho_normals(-dir)
				current_transforms[i - 1].origin = joint_a + dir * segment_lengths[i - 1]
				current_transforms[i - 1].basis = Basis(ortho_normals.normal_1, ortho_normals.normal_2, -dir)
			# forwards pass
			current_transforms[0].origin = base_point
			for i in (current_transforms.size() - 1):
				var joint_a: Vector3 = current_transforms[i].origin
				var joint_b: Vector3 = current_transforms[i + 1].origin
				var dir = (joint_b - joint_a).normalized()
				var ortho_normals: Dictionary = VectorHelpers.get_ortho_normals(dir)
				current_transforms[i + 1].origin = joint_a + dir * segment_lengths[i]
				current_transforms[i].basis = Basis(ortho_normals.normal_1, ortho_normals.normal_2, dir)

			current_sqr_distance = (current_transforms[current_transforms.size() - 1].origin - target_point).length_squared()
			current_iteration += 1
		current_transforms.remove_at(current_transforms.size() - 1)

	return current_transforms