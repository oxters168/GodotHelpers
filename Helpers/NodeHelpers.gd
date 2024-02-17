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
## is set to true: CapsuleShape3D, BoxShape3D, and CylinderShape3D
static func get_total_bounds_3d(parent: Node3D, from_collider: bool = false, global: bool = false) -> AABB:
	var all_descendants = get_all_descendants(parent)
	all_descendants.append(parent)
	var total_bounds: AABB
	var first_bounds = true
	for child in all_descendants:
		if child is Node3D:
			var child_bounds = get_bounds_3d(child, from_collider, global)
			if (first_bounds):
				total_bounds = child_bounds
				first_bounds = false
			else:
				total_bounds = total_bounds.merge(child_bounds)
			# print_debug("Merging ", child_bounds, " with ", old_total_bounds, " = ", total_bounds)
	return total_bounds

## Calculate the bounds of the given node.
## This function is incomplete and only currently works with the following collision shapes when [param from_collider]
## is set to true: CapsuleShape3D, BoxShape3D, and CylinderShape3D
static func get_bounds_3d(obj: Node3D, from_collider: bool = false, global: bool = false):
	var bounds: AABB = AABB()
	if from_collider && obj is CollisionShape3D:
		var casted_obj = (obj as CollisionShape3D)
		var size = Vector3.ZERO
		if casted_obj.shape is CapsuleShape3D:
			var casted_shape = (casted_obj.shape as CapsuleShape3D)
			size = Vector3(casted_shape.radius * 2, casted_shape.height, casted_shape.radius * 2)
			# print_debug("Found CapsuleShape3D with size ", size)
		elif casted_obj.shape is BoxShape3D:
			var casted_shape = (casted_obj.shape as BoxShape3D)
			size = casted_shape.size
			# print_debug("Found BoxShape3D with size ", size)
		elif casted_obj.shape is CylinderShape3D:
			var casted_shape = (casted_obj.shape as CylinderShape3D)
			size = Vector3(casted_shape.radius * 2, casted_shape.height, casted_shape.radius * 2)
			# print_debug("Found CylinderShape3D with size ", size)
		bounds.position = obj.position - size / 2
		bounds.size = size
	elif !from_collider && obj is MeshInstance3D:
		var casted_obj = (obj as MeshInstance3D)
		bounds = casted_obj.get_aabb()
	
	if global && obj.get_parent() != null && obj.get_parent() is Node3D:
		var parent = (obj.get_parent() as Node3D)
		var temp_bounds = AABB(bounds)
		bounds.position = parent.to_global(temp_bounds.position)
		bounds.end = parent.to_global(temp_bounds.end)
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

## Returns a vector representing the global right direction of the given object
## Shorthand for node.global_transform.basis.x.normalized()
static func get_global_right(node: Node) -> Vector3:
	return -node.global_transform.basis.x.normalized()
## Returns a vector representing the global up direction of the given object
## Shorthand for node.global_transform.basis.y.normalized()
static func get_global_up(node: Node) -> Vector3:
	return node.global_transform.basis.y.normalized()
## Returns a vector representing the global forward direction of the given object
## Shorthand for -node.global_transform.basis.z.normalized()
static func get_global_forward(node: Node) -> Vector3:
	return node.global_transform.basis.z.normalized()
## Returns a vector representing the global left direction of the given object
## Shorthand for -node.global_transform.basis.x.normalized()
static func get_global_left(node: Node) -> Vector3:
	return node.global_transform.basis.x.normalized()
## Returns a vector representing the global down direction of the given object
## Shorthand for -node.global_transform.basis.y.normalized()
static func get_global_down(node: Node) -> Vector3:
	return -node.global_transform.basis.y.normalized()
## Returns a vector representing the global back direction of the given object
## Shorthand for node.global_transform.basis.z.normalized()
static func get_global_back(node: Node) -> Vector3:
	return -node.global_transform.basis.z.normalized()

## Returns a vector representing the local right direction of the given object
## Shorthand for node.transform.basis.x.normalized()
static func get_local_right(node: Node) -> Vector3:
	return -node.transform.basis.x.normalized()
## Returns a vector representing the local up direction of the given object
## Shorthand for node.transform.basis.y.normalized()
static func get_local_up(node: Node) -> Vector3:
	return node.transform.basis.y.normalized()
## Returns a vector representing the local forward direction of the given object
## Shorthand for -node.transform.basis.z.normalized()
static func get_local_forward(node: Node) -> Vector3:
	return node.transform.basis.z.normalized()
## Returns a vector representing the local left direction of the given object
## Shorthand for -node.transform.basis.x.normalized()
static func get_local_left(node: Node) -> Vector3:
	return node.transform.basis.x.normalized()
## Returns a vector representing the local down direction of the given object
## Shorthand for -node.transform.basis.y.normalized()
static func get_local_down(node: Node) -> Vector3:
	return -node.transform.basis.y.normalized()
## Returns a vector representing the local back direction of the given object
## Shorthand for node.transform.basis.z.normalized()
static func get_local_back(node: Node) -> Vector3:
	return -node.transform.basis.z.normalized()
