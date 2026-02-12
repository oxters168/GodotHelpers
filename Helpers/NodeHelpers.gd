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
