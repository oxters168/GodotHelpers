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