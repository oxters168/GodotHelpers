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

## Calculates the global transforms needed to set up the given segments to reach towards the [param target_transform] from the [param base_point] using forwards and backwards reaching inverse kinematics.
## [param segment_transforms] is the array containing the current base global transforms of the segments. The output array contains the new global transforms for how to place the segments. The first
## value in this array represents the base position and orientation of the first segment starting from the [param base_point], the second value would be the transform of the next segment whose base
## position would be at the end of the first segment and whose orientation would face the next segment, and so on. The [param segment_lengths] array contains the length of each segment where the
## [param segment_transforms] array values make up the base of each segment. This means that [param segment_lengths] will always be the same size as [param segment_transforms].
## [param distance_margin_error] is how far the minimum distance the last joint needs to reach from [param target_transform] to be considered a successful fabrik solution and end the solve loop.
## [param max_iterations] is the maximum amount of times to run the fabrik solver before [param distance_margin_error] is reached. The [param angle_constraints] is also the same length as [param segment_transforms]
## and contains the lower and upper angular limits for each joint in their local spacial axes in radians (should be between -PI and PI). If [param angle_constraints] is not provided then the solver
## will have no angular limits. [param root_basis] is only needed if [param angle_constraints] is provided and is the global basis of the parent node of the first transform in [param segment_transforms].
## Reference: https://www.youtube.com/watch?v=lJCeHXXPf5w
static func fabrik_solve_3d(
	base_point: Vector3,
	target_transform: Transform3D,
	segment_transforms: Array[Transform3D],
	segment_lengths: Array[float],
	use_target_rot: bool = false,
	max_iterations: int = 16,
	distance_margin_error: float = 0.01,
	angle_constraints: Array[AngularLimits3D] = [],
	root_basis: Basis = Basis(),
) -> Array[Transform3D]:
	assert(segment_lengths != null && segment_lengths.size() == segment_transforms.size(), "FABRIK solver received incorrect amount of segment lengths")
	assert(angle_constraints == null || angle_constraints.size() == 0 || angle_constraints.size() == segment_transforms.size(), "FABRIK solver received incorrect amount of angle constraints")

	# deep copy the segment transforms array
	var current_transforms: Array[Transform3D] = []
	for segment_transform in segment_transforms:
		current_transforms.append(Transform3D(segment_transform))

	var total_reach_length: float = segment_lengths.reduce(func(accum, length): return accum + length)
	var target_base_diff: Vector3 = target_transform.origin - base_point
	var angles_constrained: bool = angle_constraints != null && angle_constraints.size() > 0
	# if there are no angular constraints and target is too far to reach then set resulting positions to be in a straight line to the target
	if !use_target_rot && !angles_constrained && (total_reach_length * total_reach_length) < target_base_diff.length_squared():
		var target_base_dir: Vector3 = target_base_diff.normalized()
		var ortho_normals: Dictionary = VectorHelpers.get_ortho_normals(target_base_dir)
		var straight_basis: Basis = Basis(ortho_normals.normal_1, ortho_normals.normal_2, target_base_dir)
		current_transforms[0].basis = straight_basis
		current_transforms[0].origin = base_point
		for i in range(1, segment_transforms.size()):
			current_transforms[i].basis = straight_basis
			current_transforms[i].origin = current_transforms[i - 1].origin + target_base_dir * segment_lengths[i - 1]
	else:
		# create angle constrainer function 
		var constrain_angles = func(current_basis: Basis, parent_basis: Basis, constraints: AngularLimits3D) -> Basis:
			var local_euler: Vector3 = BasisHelpers.to_local(parent_basis, current_basis).get_euler()
			local_euler = Vector3(wrapf(local_euler.x, -PI, PI), wrapf(local_euler.y, -PI, PI), wrapf(local_euler.z, -PI, PI))
			var angle_x = clampf(local_euler.x, constraints.lower_limit.x, constraints.upper_limit.x)
			var angle_y = local_euler.y
			var angle_z = local_euler.z
			local_euler = Vector3(angle_x, angle_y, angle_z)
			var corrected_basis: Basis = Basis.from_euler(local_euler)
			local_euler = corrected_basis.get_euler()
			local_euler = Vector3(wrapf(local_euler.x, -PI, PI), wrapf(local_euler.y, -PI, PI), wrapf(local_euler.z, -PI, PI))
			angle_x = local_euler.x
			angle_y = clampf(local_euler.y, constraints.lower_limit.y, constraints.upper_limit.y)
			angle_z = local_euler.z
			local_euler = Vector3(angle_x, angle_y, angle_z)
			corrected_basis = Basis.from_euler(local_euler)
			local_euler = corrected_basis.get_euler()
			local_euler = Vector3(wrapf(local_euler.x, -PI, PI), wrapf(local_euler.y, -PI, PI), wrapf(local_euler.z, -PI, PI))
			angle_x = local_euler.x
			angle_y = local_euler.y
			angle_z = clampf(local_euler.z, constraints.lower_limit.z, constraints.upper_limit.z)
			local_euler = Vector3(angle_x, angle_y, angle_z)
			corrected_basis = BasisHelpers.to_global(parent_basis, Basis.from_euler(local_euler))
			return corrected_basis
		# create backwards pass function
		var backwards_pass = func(start_transform: Transform3D, transforms: Array[Transform3D], use_target_rot_: bool = false, angle_constraints_: Array[AngularLimits3D] = []) -> void:
			transforms[transforms.size() - 1] = start_transform
			for i in range(transforms.size() - 1, 0, -1):
				var joint_a: Vector3 = transforms[i].origin
				var joint_b: Vector3 = transforms[i - 1].origin
				
				var basis: Basis = start_transform.basis
				if !use_target_rot_ || i < transforms.size() - 1:
					var dir: Vector3 = (joint_b - joint_a).normalized()
					var right: Vector3 = (-dir).cross(BasisHelpers.get_right(transforms[i - 1].basis)).normalized()
					var up: Vector3 = (-dir).cross(right).normalized()
					basis = Basis(right, up, -dir)
				
				if angle_constraints_ != null && angle_constraints_.size() > 0:
					var parent_basis: Basis = transforms[i - 2].basis if i > 1 else root_basis
					var constraints: AngularLimits3D = angle_constraints_[i - 1]
					basis = constrain_angles.call(basis, parent_basis, constraints)
				
				transforms[i - 1].origin = joint_a + BasisHelpers.get_back(basis) * segment_lengths[i - 1]
				transforms[i - 1].basis = basis
		# create forwards pass function
		var forwards_pass = func(start_point: Vector3, transforms: Array[Transform3D], angle_constraints_: Array[AngularLimits3D] = [], use_target_rot_: bool = false, target_rotation_: Basis = Basis()) -> void:
			transforms[0].origin = start_point
			for i in (transforms.size() - 1):
				var joint_a: Vector3 = transforms[i].origin
				var joint_b: Vector3 = transforms[i + 1].origin

				var basis: Basis = target_rotation_
				if i < transforms.size() - 2 || !use_target_rot_:
					var dir: Vector3 = (joint_b - joint_a).normalized()
					var right: Vector3 = dir.cross(BasisHelpers.get_right(transforms[i + 1].basis)).normalized()
					var up: Vector3 = dir.cross(right).normalized()
					basis = Basis(right, up, dir)

				if angle_constraints_ != null && angle_constraints_.size() > 0:
					var parent_basis: Basis = transforms[i - 1].basis if i > 0 else root_basis
					var constraints: AngularLimits3D = angle_constraints_[i]
					basis = constrain_angles.call(basis, parent_basis, constraints)

				transforms[i + 1].origin = joint_a + BasisHelpers.get_forward(basis) * segment_lengths[i]
				transforms[i].basis = basis

		# backup the original segment transforms
		var prev_transforms: Array[Transform3D] = current_transforms
		# append an extra point to represent the target
		current_transforms.append(target_transform)

		var sqr_dist_margin: float = distance_margin_error * distance_margin_error
		var current_sqr_distance: float = Constants.FLOAT_MAX
		var current_iteration: int = 0
		while current_sqr_distance > sqr_dist_margin && current_iteration < max_iterations:
			backwards_pass.call(target_transform, current_transforms, use_target_rot)
			forwards_pass.call(base_point, current_transforms, angle_constraints, use_target_rot, target_transform.basis)
			current_sqr_distance = (current_transforms[current_transforms.size() - 1].origin - target_transform.origin).length_squared()
			current_iteration += 1
		# remove the extra point we added earlier which represents the target
		current_transforms.remove_at(current_transforms.size() - 1)
		# if the solver did not improve on the previous given transforms, then restore them
		if current_sqr_distance > (prev_transforms[prev_transforms.size() - 1].origin - target_transform.origin).length_squared():
			current_transforms = prev_transforms

	return current_transforms

## Converts the [param bone_name] to a body part using the given [param bone_to_part] dictionary which can be generated by [member SkeletonHelpers.create_bone_to_part_dict]
static func bone_name_to_body_part(bone_to_part: Dictionary, bone_name: String) -> Enums.BipedalBodyPart:
	if bone_to_part.has(bone_name):
		return bone_to_part[bone_name]
	else:
		return Enums.BipedalBodyPart.UNKNOWN
## Converts the [param body_part] to a bone name using the given [param bone_to_part] dictionary which can be generated by [member SkeletonHelpers.create_bone_to_part_dict]
static func body_part_to_bone_name(bone_to_part: Dictionary, body_part: Enums.BipedalBodyPart) -> String:
	var bone_name = null
	var key_index = bone_to_part.values().find(body_part)
	if key_index >= 0:
		bone_name = bone_to_part.keys()[key_index]
	return bone_name

## Attempts to create a dictionary from the bone names of [param skeleton] to a corresponding [enum Enums.BipedalBodyPart]
static func create_bone_to_part_dict(skeleton: Skeleton3D) -> Dictionary:
	var contains_extra = func(bone_name: String, expected_name: String, extra: String) -> bool:
		return bone_name.substr(bone_name.find(expected_name) + expected_name.length()).contains(extra)
	var is_left_bone = func(bone_name: String, expected_name: String) -> bool:
		return contains_extra.call(bone_name, expected_name, "l")

	var result_dict: Dictionary = {}
	var has_pelvis: bool = false
	for bone_id in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(bone_id)
		var comparable_bone_name = bone_name.to_lower()
		var body_part: Enums.BipedalBodyPart = Enums.BipedalBodyPart.UNKNOWN
		if comparable_bone_name.contains("foot"):
			var is_left = is_left_bone.call(comparable_bone_name, "foot")
			body_part = Enums.BipedalBodyPart.FOOT_L if is_left else Enums.BipedalBodyPart.FOOT_R
		elif comparable_bone_name.contains("shin"):
			var is_left = is_left_bone.call(comparable_bone_name, "shin")
			body_part = Enums.BipedalBodyPart.SHIN_L if is_left else Enums.BipedalBodyPart.SHIN_R
		elif comparable_bone_name.contains("calf"):
			var is_left = is_left_bone.call(comparable_bone_name, "calf")
			body_part = Enums.BipedalBodyPart.SHIN_L if is_left else Enums.BipedalBodyPart.SHIN_R
		elif comparable_bone_name.contains("quad"):
			var is_left = is_left_bone.call(comparable_bone_name, "quad")
			body_part = Enums.BipedalBodyPart.QUAD_L if is_left else Enums.BipedalBodyPart.QUAD_R
		elif comparable_bone_name.contains("thigh"):
			var is_left = is_left_bone.call(comparable_bone_name, "thigh")
			body_part = Enums.BipedalBodyPart.QUAD_L if is_left else Enums.BipedalBodyPart.QUAD_R
		elif comparable_bone_name.contains("hand"):
			var is_left = is_left_bone.call(comparable_bone_name, "hand")
			body_part = Enums.BipedalBodyPart.HAND_L if is_left else Enums.BipedalBodyPart.HAND_R
		elif comparable_bone_name.contains("forearm"):
			var is_left = is_left_bone.call(comparable_bone_name, "forearm")
			body_part = Enums.BipedalBodyPart.FOREARM_L if is_left else Enums.BipedalBodyPart.FOREARM_R
		elif comparable_bone_name.contains("lowerarm"):
			var is_left = is_left_bone.call(comparable_bone_name, "lowerarm")
			body_part = Enums.BipedalBodyPart.FOREARM_L if is_left else Enums.BipedalBodyPart.FOREARM_R
		elif comparable_bone_name.contains("upperarm"):
			var is_left = is_left_bone.call(comparable_bone_name, "upperarm")
			body_part = Enums.BipedalBodyPart.ARM_L if is_left else Enums.BipedalBodyPart.ARM_R
		elif comparable_bone_name.contains("arm"):
			var is_left = is_left_bone.call(comparable_bone_name, "arm")
			body_part = Enums.BipedalBodyPart.ARM_L if is_left else Enums.BipedalBodyPart.ARM_R
		elif comparable_bone_name.contains("spine"):
			var is_first = contains_extra.call(comparable_bone_name, "spine", "1")
			var is_second = contains_extra.call(comparable_bone_name, "spine", "2")
			# var is_third = _contains_extra(comparable_bone_name, "spine", "3")
			body_part = Enums.BipedalBodyPart.SPINE_1 if (is_first && !has_pelvis) else Enums.BipedalBodyPart.SPINE_2 if (is_first && has_pelvis) || (is_second && !has_pelvis) else Enums.BipedalBodyPart.SPINE_3
		elif comparable_bone_name.contains("pelvis"):
			body_part = Enums.BipedalBodyPart.SPINE_1
		elif comparable_bone_name.contains("neck"):
			body_part = Enums.BipedalBodyPart.NECK
		elif comparable_bone_name.contains("head"):
			body_part = Enums.BipedalBodyPart.HEAD
		if body_part != Enums.BipedalBodyPart.UNKNOWN:
			result_dict[bone_name] = body_part
	return result_dict
## Returns the name of the root bone or an empty string if one was not found
static func get_root_bone_name(skeleton: Skeleton3D) -> String:
	var root_bone = ""
	for bone_id in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(bone_id)
		var comparable_bone_name = bone_name.to_lower()
		if comparable_bone_name.contains("pelvis"):
			root_bone = bone_name
			break
		elif comparable_bone_name.contains("hips"):
			root_bone = bone_name
			break
	return root_bone
## Returns the global position of the [param body_part] of the [param skeleton] using [param bone_to_part] to identify the bone name of the body part. [param bone_to_part] can be
## generated using [member SkeletonHelpers.bone_name_to_body_part].
static func get_global_rest_pos(skeleton: Skeleton3D, bone_to_part: Dictionary, body_part: Enums.BipedalBodyPart) -> Vector3:
	var bone_name = body_part_to_bone_name(bone_to_part, body_part)
	return skeleton.to_global(skeleton.get_bone_global_rest(skeleton.find_bone(bone_name)).origin)
## Returns the global rotation of the [param body_part] of the [param skeleton] using [param bone_to_part] to identify the bone name of the body part. [param bone_to_part] can be
## generated using [member SkeletonHelpers.bone_name_to_body_part].
static func get_global_rest_rot(skeleton: Skeleton3D, bone_to_part: Dictionary, body_part: Enums.BipedalBodyPart) -> Quaternion:
	var bone_name = body_part_to_bone_name(bone_to_part, body_part)
	return QuatHelpers.to_global(skeleton.global_basis.get_rotation_quaternion(), skeleton.get_bone_global_rest(skeleton.find_bone(bone_name)).basis.get_rotation_quaternion())
## Attempts to calculate the size ratios of each body part within the [param skeleton] in relation to the height of the [param skeleton] and returns
## a value holding all measurements
static func calculate_size_ratios(skeleton: Skeleton3D, bone_to_part: Dictionary) -> BipedalMeasurements:
	var foot_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.FOOT_L)
	var left_knee_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.SHIN_L)
	var right_knee_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.SHIN_R)
	var thigh_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.QUAD_L)
	var wrist_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.HAND_L)
	var elbow_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.FOREARM_L)
	var left_shoulder_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.ARM_L)
	var right_shoulder_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.ARM_R)
	var neck_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.NECK)
	var head_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.HEAD)
	var hip_pos = get_global_rest_pos(skeleton, bone_to_part, Enums.BipedalBodyPart.SPINE_1)
	
	var neck_height = (head_pos - neck_pos).length()
	var head_height = neck_height * 2.5
	var torso_width = (right_shoulder_pos - left_shoulder_pos).length()
	var torso_height = (neck_pos - hip_pos).length()
	var bicep_length = (elbow_pos - left_shoulder_pos).length()
	var forearm_length = (wrist_pos - elbow_pos).length()
	var knee_distance = (left_knee_pos - right_knee_pos).length()
	var thigh_height = (left_knee_pos - thigh_pos).length()
	var shin_height = (foot_pos - left_knee_pos).length()
	var foot_height = abs(foot_pos.y)

	var calculated_ratios: BipedalMeasurements = BipedalMeasurements.new()
	calculated_ratios.ragdoll_height = foot_height + shin_height + thigh_height + torso_height + neck_height + head_height

	calculated_ratios.head_height_ratio = head_height / calculated_ratios.ragdoll_height
	calculated_ratios.head_radius_ratio = calculated_ratios.head_height_ratio * 0.42
	calculated_ratios.neck_height_ratio = neck_height / calculated_ratios.ragdoll_height
	calculated_ratios.neck_radius_ratio = calculated_ratios.neck_height_ratio * 0.4

	calculated_ratios.torso_width_ratio = torso_width / calculated_ratios.ragdoll_height
	calculated_ratios.torso_height_ratio = torso_height / calculated_ratios.ragdoll_height
	calculated_ratios.torso_thickness_ratio = torso_width * 0.28

	calculated_ratios.bicep_length_ratio = bicep_length / calculated_ratios.ragdoll_height
	calculated_ratios.forearm_length_ratio = forearm_length / calculated_ratios.ragdoll_height
	calculated_ratios.arm_radius_ratio = 0.04
	calculated_ratios.hand_length_ratio = bicep_length * 0.42

	calculated_ratios.knee_distance_ratio = knee_distance / calculated_ratios.ragdoll_height
	calculated_ratios.thigh_height_ratio = thigh_height / calculated_ratios.ragdoll_height
	calculated_ratios.shin_height_ratio = shin_height / calculated_ratios.ragdoll_height
	calculated_ratios.foot_height_ratio = foot_height / calculated_ratios.ragdoll_height
	calculated_ratios.leg_radius_ratio = 0.04
	calculated_ratios.foot_length_ratio = thigh_height * 0.33
	return calculated_ratios
