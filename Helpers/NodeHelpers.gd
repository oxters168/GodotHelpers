class_name NodeHelpers

## Returns the scene node object that the given node belongs to
static func get_scene_node(node: Node):
	var root = node.get_tree().get_root()
	return root.get_child(root.get_child_count() - 1)

## Goes up the node tree until it finds a parent of the given type and returns it
## Returns null if a parent of the given type cannot be found
static func get_parent_of_type(current: Node, type, include_self = true):
	var check_par: Node = current if include_self else current.get_parent()
	if (check_par != null && is_instance_of(check_par, type)):
		return check_par
	elif check_par != null:
		return get_parent_of_type(check_par, type, false)
	else:
		return null
## Goes down the node tree until it finds a parent of the given type and returns it
## Returns null if a parent of the given type cannot be found
static func get_child_of_type(current: Node, child_type, include_self = true, include_all_descendants = true):
	if include_self and is_instance_of(current, child_type):
		return current
	var immediate_children = current.get_children()
	for child in immediate_children:
		if is_instance_of(child, child_type):
			return child
	if include_all_descendants:
		for child in immediate_children:
			var result = get_child_of_type(child, child_type, false)
			if result != null:
				return result
	return null
## Returns an array of all children with the given type
static func get_children_of_type(current: Node, child_type, include_self = true, include_all_descendants = true):
	var output = []
	if include_self and is_instance_of(current, child_type):
		output.append(current)
	var immediate_children = current.get_children()
	for child in immediate_children:
		if is_instance_of(child, child_type):
			output.append(child)
	if include_all_descendants:
		for child in immediate_children:
			output.append_array(get_children_of_type(child, child_type, false))
	return output

## Returns an array of all children, grand-children, grand-grand-children, etc
static func get_all_descendants(parent: Node) -> Array[Node]:
	var all_descendants: Array[Node] = []
	var immediate_children = parent.get_children()
	all_descendants.append_array(immediate_children)
	for child in immediate_children:
		all_descendants.append_array(get_all_descendants(child))
	return all_descendants

## Calculate the total bounds of the given node.
## This function is incomplete and only currently works with the following collision shapes when [param from_collider]
## is set to true: CapsuleShape3D, BoxShape3D, CylinderShape3D, SphereShape3D, and ConvexPolygonShape3D
static func get_total_bounds_3d(parent: Node3D, from_collider: bool = false, global: bool = false) -> AABB:
	var all_descendants = get_all_descendants(parent)
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
						var new_start: Vector3 = parent.to_local(child.to_global(child_bounds.position))
						var new_end: Vector3 = parent.to_local(child.to_global(child_bounds.end))
						new_start = Vector3(min(new_start.x, new_end.x), min(new_start.y, new_end.y), min(new_start.z, new_end.z))
						new_end = Vector3(max(new_start.x, new_end.x), max(new_start.y, new_end.y), max(new_start.z, new_end.z))
						total_bounds = AABB(new_start, abs(new_end - new_start))
					first_bounds = false
				else:
					if global:
						# print("Merging globally")
						total_bounds = total_bounds.merge(child_bounds)
					else:
						# print("Merging locally")
						var new_start: Vector3 = parent.to_local(child.to_global(child_bounds.position))
						var new_end: Vector3 = parent.to_local(child.to_global(child_bounds.end))
						new_start = Vector3(min(new_start.x, new_end.x), min(new_start.y, new_end.y), min(new_start.z, new_end.z))
						new_end = Vector3(max(new_start.x, new_end.x), max(new_start.y, new_end.y), max(new_start.z, new_end.z))
						total_bounds = total_bounds.merge(AABB(new_start, abs(new_end - new_start)))
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
	
	if bounds and global:# && obj.get_parent() != null && obj.get_parent() is Node3D:
		# var parent = (obj.get_parent() as Node3D)
		var global_start: Vector3 = obj.to_global(bounds.position)
		var global_right_start: Vector3 = obj.to_global(bounds.position + Vector3.RIGHT * bounds.size.x)
		var global_above_start: Vector3 = obj.to_global(bounds.position + Vector3.UP * bounds.size.y)
		var global_back_start: Vector3 = obj.to_global(bounds.position + Vector3.BACK * bounds.size.z)
		var global_above_right: Vector3 = obj.to_global(bounds.position + Vector3.RIGHT * bounds.size.x + Vector3.UP * bounds.size.y)
		var global_above_back: Vector3 = obj.to_global(bounds.position + Vector3.UP * bounds.size.y + Vector3.BACK * bounds.size.z)
		var global_below_end: Vector3 = obj.to_global(bounds.end + Vector3.DOWN * bounds.size.y)
		var global_end: Vector3 = obj.to_global(bounds.end)
		var min_x: float = min(global_start.x, global_right_start.x, global_above_start.x, global_back_start.x, global_above_right.x, global_above_back.x, global_below_end.x, global_end.x)
		var min_y: float = min(global_start.y, global_right_start.y, global_above_start.y, global_back_start.y, global_above_right.y, global_above_back.y, global_below_end.y, global_end.y)
		var min_z: float = min(global_start.z, global_right_start.z, global_above_start.z, global_back_start.z, global_above_right.z, global_above_back.z, global_below_end.z, global_end.z)
		var max_x: float = max(global_start.x, global_right_start.x, global_above_start.x, global_back_start.x, global_above_right.x, global_above_back.x, global_below_end.x, global_end.x)
		var max_y: float = max(global_start.y, global_right_start.y, global_above_start.y, global_back_start.y, global_above_right.y, global_above_back.y, global_below_end.y, global_end.y)
		var max_z: float = max(global_start.z, global_right_start.z, global_above_start.z, global_back_start.z, global_above_right.z, global_above_back.z, global_below_end.z, global_end.z)
		# DebugDraw.draw_box(global_start, Vector3.ONE * 0.1, Color.GREEN)
		# DebugDraw.draw_box(global_end, Vector3.ONE * 0.1, Color.RED)
		var min_pos: Vector3 = Vector3(min_x, min_y, min_z)
		var max_pos: Vector3 = Vector3(max_x, max_y, max_z)
		DebugDraw.draw_box(min_pos, Vector3.ONE * 0.1, Color.GREEN)
		DebugDraw.draw_box(max_pos, Vector3.ONE * 0.1, Color.RED)
		# bounds = AABB(Vector3(min(new_start.x, new_end.x), min(new_start.y, new_end.y), min(new_start.z, new_end.z)), abs(new_end - new_start))
		# bounds = AABB(new_start, bounds.size)
		# print(str(bounds.position, " => ", new_start, " ___ ", bounds.end, " => ", new_end))
		bounds.position = min_pos
		bounds.end = max_pos
		# bounds.size = new_end - new_start
	return bounds

## Serializes the given node to a file at the given filepath
static func save_node_as_scene(root: Node, abs_path: String):
	var scene = PackedScene.new()
	var error = scene.pack(root)
	if (error == OK):
		error = ResourceSaver.save(scene, abs_path) 
		if (error != OK):
			push_error("An error occurred while saving the scene to disk")
	else:
		push_error("An error occured while packing the scene")
	return error

## Returns a Vector3i value based on the node's Vector3 position given a step amount and offset
static func get_discrete_pos(node: Node, space_step: Vector3, offset: Vector3 = Vector3.ZERO):
	return VectorHelpers.get_discrete_pos(node.global_transform.origin, space_step, offset)

## Returns a vector representing the global right direction of the given object.
## Shorthand for -node.global_transform.basis.x.normalized()
static func get_global_right(node: Node) -> Vector3:
	return BasisHelpers.get_right(node.global_transform.basis)
## Returns a vector representing the global up direction of the given object.
## Shorthand for node.global_transform.basis.y.normalized()
static func get_global_up(node: Node) -> Vector3:
	return BasisHelpers.get_up(node.global_transform.basis)
## Returns a vector representing the global forward direction of the given object.
## Shorthand for node.global_transform.basis.z.normalized()
static func get_global_forward(node: Node) -> Vector3:
	return BasisHelpers.get_forward(node.global_transform.basis)
## Returns a vector representing the global left direction of the given object.
## Shorthand for node.global_transform.basis.x.normalized()
static func get_global_left(node: Node) -> Vector3:
	return BasisHelpers.get_left(node.global_transform.basis)
## Returns a vector representing the global down direction of the given object.
## Shorthand for -node.global_transform.basis.y.normalized()
static func get_global_down(node: Node) -> Vector3:
	return BasisHelpers.get_down(node.global_transform.basis)
## Returns a vector representing the global back direction of the given object.
## Shorthand for -node.global_transform.basis.z.normalized()
static func get_global_back(node: Node) -> Vector3:
	return BasisHelpers.get_back(node.global_transform.basis)

## Returns a vector representing the local right direction of the given object.
## Shorthand for -node.transform.basis.x.normalized()
static func get_local_right(node: Node) -> Vector3:
	return BasisHelpers.get_right(node.transform.basis)
## Returns a vector representing the local up direction of the given object.
## Shorthand for node.transform.basis.y.normalized()
static func get_local_up(node: Node) -> Vector3:
	return BasisHelpers.get_up(node.transform.basis)
## Returns a vector representing the local forward direction of the given object.
## Shorthand for node.transform.basis.z.normalized()
static func get_local_forward(node: Node) -> Vector3:
	return BasisHelpers.get_forward(node.transform.basis)
## Returns a vector representing the local left direction of the given object.
## Shorthand for node.transform.basis.x.normalized()
static func get_local_left(node: Node) -> Vector3:
	return BasisHelpers.get_left(node.transform.basis)
## Returns a vector representing the local down direction of the given object.
## Shorthand for -node.transform.basis.y.normalized()
static func get_local_down(node: Node) -> Vector3:
	return BasisHelpers.get_down(node.transform.basis)
## Returns a vector representing the local back direction of the given object.
## Shorthand for -node.transform.basis.z.normalized()
static func get_local_back(node: Node) -> Vector3:
	return BasisHelpers.get_back(node.transform.basis)
