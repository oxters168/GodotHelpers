class_name BoundsHelpers

## Calculate the total bounds of the given node.
## This function is incomplete and only currently works with the following collision shapes when [param from_collider]
## is set to true: CapsuleShape3D, BoxShape3D, CylinderShape3D, SphereShape3D, and ConvexPolygonShape3D
static func get_total_bounds_3d(parent: Node3D, from_collider: bool = false, global: bool = false) -> AABB:
	var all_descendants = NodeHelpers.get_all_descendants(parent)
	all_descendants.append(parent)
	var total_bounds: AABB
	var first_bounds = true
	for child in all_descendants:
		if child is Node3D:
			var child_bounds = get_bounds_3d(child, from_collider, global)
			if child_bounds:
				if first_bounds:
					if global:
						# print("Setting first globally")
						total_bounds = child_bounds
					else:
						# print("Setting first locally")
						# var globalized_bounds: AABB = transform_bounds(child_bounds, child.global_transform)
						# total_bounds = transform_bounds(globalized_bounds, parent.global_transform.inverse())
						total_bounds = transform_bounds(child_bounds, parent.global_transform.inverse() * child.global_transform)
					first_bounds = false
				else:
					if global:
						# print("Merging globally")
						total_bounds = total_bounds.merge(child_bounds)
					else:
						# print("Merging locally")
						# var globalized_bounds: AABB = transform_bounds(child_bounds, child.global_transform)
						# total_bounds = total_bounds.merge(transform_bounds(globalized_bounds, parent.global_transform.inverse()))
						total_bounds = total_bounds.merge(transform_bounds(child_bounds, parent.global_transform.inverse() * child.global_transform))
				# print_debug("Merging ", child_bounds, " with ", old_total_bounds, " = ", total_bounds)
	# print(str("final: ", total_bounds.position, " ___ ", total_bounds.end))
	return (total_bounds if not first_bounds else AABB((parent.global_position if global else parent.position), Vector3.ZERO))

## Calculate the bounds of the given node.
## This function is incomplete and only currently works with the following collision shapes when [param from_collider]
## is set to true: CapsuleShape3D, BoxShape3D, CylinderShape3D, SphereShape3D, and ConvexPolygonShape3D
static func get_bounds_3d(obj: Node3D, from_collider: bool = false, global: bool = false) -> AABB:
	var bounds: AABB = AABB()
	if from_collider && obj is CollisionShape3D:
		var casted_obj: CollisionShape3D = (obj as CollisionShape3D)
		var center: Vector3 = Vector3.ZERO
		var size: Vector3 = Vector3.ZERO
		if casted_obj.shape is CapsuleShape3D:
			var casted_shape: CapsuleShape3D = casted_obj.shape as CapsuleShape3D
			size = Vector3(casted_shape.radius * 2, casted_shape.height, casted_shape.radius * 2)
			# print_debug("Found CapsuleShape3D with size ", size)
		elif casted_obj.shape is BoxShape3D:
			var casted_shape: BoxShape3D = casted_obj.shape as BoxShape3D
			size = casted_shape.size
			# print_debug("Found BoxShape3D with size ", size)
		elif casted_obj.shape is CylinderShape3D:
			var casted_shape: CylinderShape3D = casted_obj.shape as CylinderShape3D
			size = Vector3(casted_shape.radius * 2, casted_shape.height, casted_shape.radius * 2)
			# print_debug("Found CylinderShape3D with size ", size)
		elif casted_obj.shape is SphereShape3D:
			var casted_shape: SphereShape3D = casted_obj.shape as SphereShape3D
			size = Vector3.ONE * casted_shape.radius * 2
		elif casted_obj.shape is ConvexPolygonShape3D:
			var casted_shape: ConvexPolygonShape3D = casted_obj.shape as ConvexPolygonShape3D
			center = MeshHelpers.calculate_center_from_points(casted_shape.points)
			size = MeshHelpers.calculate_size_from_points(casted_shape.points)
		bounds.position = center - size / 2
		bounds.size = size
	elif !from_collider && obj is MeshInstance3D:
		var casted_obj = (obj as MeshInstance3D)
		bounds = casted_obj.get_aabb()
	
	if bounds and global:
		bounds = transform_bounds(bounds, obj.global_transform)
	return bounds

## Apply a [Transform3D] to a bounds and receive the resulting bounds
static func transform_bounds(bounds: AABB, transform: Transform3D) -> AABB:
	var global_start: Vector3 = transform * (bounds.position)
	var global_right_start: Vector3 = transform * (bounds.position + Vector3.RIGHT * bounds.size.x)
	var global_above_start: Vector3 = transform * (bounds.position + Vector3.UP * bounds.size.y)
	var global_back_start: Vector3 = transform * (bounds.position + Vector3.BACK * bounds.size.z)
	var global_above_right: Vector3 = transform * (bounds.position + Vector3.RIGHT * bounds.size.x + Vector3.UP * bounds.size.y)
	var global_above_back: Vector3 = transform * (bounds.position + Vector3.UP * bounds.size.y + Vector3.BACK * bounds.size.z)
	var global_below_end: Vector3 = transform * (bounds.end + Vector3.DOWN * bounds.size.y)
	var global_end: Vector3 = transform * (bounds.end)
	var min_x: float = min(global_start.x, global_right_start.x, global_above_start.x, global_back_start.x, global_above_right.x, global_above_back.x, global_below_end.x, global_end.x)
	var min_y: float = min(global_start.y, global_right_start.y, global_above_start.y, global_back_start.y, global_above_right.y, global_above_back.y, global_below_end.y, global_end.y)
	var min_z: float = min(global_start.z, global_right_start.z, global_above_start.z, global_back_start.z, global_above_right.z, global_above_back.z, global_below_end.z, global_end.z)
	var max_x: float = max(global_start.x, global_right_start.x, global_above_start.x, global_back_start.x, global_above_right.x, global_above_back.x, global_below_end.x, global_end.x)
	var max_y: float = max(global_start.y, global_right_start.y, global_above_start.y, global_back_start.y, global_above_right.y, global_above_back.y, global_below_end.y, global_end.y)
	var max_z: float = max(global_start.z, global_right_start.z, global_above_start.z, global_back_start.z, global_above_right.z, global_above_back.z, global_below_end.z, global_end.z)
	var min_pos: Vector3 = Vector3(min_x, min_y, min_z)
	var max_pos: Vector3 = Vector3(max_x, max_y, max_z)

	return AABB(min_pos, max_pos - min_pos)