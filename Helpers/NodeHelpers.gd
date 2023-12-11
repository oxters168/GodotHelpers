class_name NodeHelpers

## Returns the scene node object that the given node belongs to
static func get_scene_node(node: Node):
	var root = node.get_tree().get_root()
	return root.get_child(root.get_child_count() - 1)

## Goes up the node tree until it finds a parent of the given type and returns it
## Returns null if a parent of the given type cannot be found
static func get_parent_of_type(current: Node, type, include_self = true):
	var parent = null
	var check_par = current if include_self else current.get_parent()
	while (check_par != null):
		if (is_instance_of(check_par, type)):
			parent = check_par
			break
	check_par = check_par.get_parent()
	return parent
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
			return get_child_of_type(child, child_type, false)
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
static func get_all_descendants(parent: Node):
	var all_descendants = []
	var immediate_children = parent.get_children()
	all_descendants.append_array(immediate_children)
	for child in immediate_children:
		all_descendants.append_array(get_all_descendants(child))
	return all_descendants

## Calculate the total collider bounds of the given node
## This function is incomplete and only currently works with CapsuleShape3D
## TODO: Add option for bounds from mesh
## TODO: Add option for local space bounds
static func get_total_bounds(parent: Node):
	var all_descendants = get_all_descendants(parent)
	var total_bounds: AABB
	var first_bounds = true
	for child in all_descendants:
		if (child is CollisionShape3D):
			var child_bounds: AABB = AABB()
			if (child.shape is CapsuleShape3D):
				var size = Vector3(child.shape.radius * 2, child.shape.height, child.shape.radius * 2)
				# re-orients the size to properly align with the object
				child_bounds.size = child.global_transform.basis.get_rotation_quaternion().inverse() * size
				child_bounds.position = child.global_transform.origin - child_bounds.size / 2
			# TODO: Add more collision shapes
			if (first_bounds):
				total_bounds = child_bounds
				first_bounds = false
			else:
				total_bounds.merge(child_bounds)
	return total_bounds

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
## Shorthand for node.global_transform.basis.x
static func get_global_right(node: Node):
	return node.global_transform.basis.x
## Returns a vector representing the global up direction of the given object
## Shorthand for node.global_transform.basis.y
static func get_global_up(node: Node):
	return node.global_transform.basis.y
## Returns a vector representing the global forward direction of the given object
## Shorthand for -node.global_transform.basis.z
static func get_global_forward(node: Node):
	return -node.global_transform.basis.z
## Returns a vector representing the global left direction of the given object
## Shorthand for -node.global_transform.basis.x
static func get_global_left(node: Node):
	return -node.global_transform.basis.x
## Returns a vector representing the global down direction of the given object
## Shorthand for -node.global_transform.basis.y
static func get_global_down(node: Node):
	return -node.global_transform.basis.y
## Returns a vector representing the global back direction of the given object
## Shorthand for node.global_transform.basis.z
static func get_global_back(node: Node):
	return node.global_transform.basis.z

## Returns a vector representing the local right direction of the given object
## Shorthand for node.transform.basis.x
static func get_local_right(node: Node):
	return node.transform.basis.x
## Returns a vector representing the local up direction of the given object
## Shorthand for node.transform.basis.y
static func get_local_up(node: Node):
	return node.transform.basis.y
## Returns a vector representing the local forward direction of the given object
## Shorthand for -node.transform.basis.z
static func get_local_forward(node: Node):
	return -node.transform.basis.z
## Returns a vector representing the local left direction of the given object
## Shorthand for -node.transform.basis.x
static func get_local_left(node: Node):
	return -node.transform.basis.x
## Returns a vector representing the local down direction of the given object
## Shorthand for -node.transform.basis.y
static func get_local_down(node: Node):
	return -node.transform.basis.y
## Returns a vector representing the local back direction of the given object
## Shorthand for node.transform.basis.z
static func get_local_back(node: Node):
	return node.transform.basis.z