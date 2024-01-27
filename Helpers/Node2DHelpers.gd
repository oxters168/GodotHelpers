class_name Node2DHelpers

## Returns a vector representing the global right direction of the given object
## Shorthand for node.get_global_transform_with_canvas().basis.x
static func get_global_right(node: Node) -> Vector2:
	return node.get_global_transform_with_canvas().x.normalized()
## Returns a vector representing the global up direction of the given object
## Shorthand for node.get_global_transform_with_canvas().basis.y
static func get_global_up(node: Node) -> Vector2:
	return -node.get_global_transform_with_canvas().y.normalized()
## Returns a vector representing the global left direction of the given object
## Shorthand for -node.get_global_transform_with_canvas().basis.x
static func get_global_left(node: Node) -> Vector2:
	return -node.get_global_transform_with_canvas().x.normalized()
## Returns a vector representing the global down direction of the given object
## Shorthand for -node.get_global_transform_with_canvas().basis.y
static func get_global_down(node: Node) -> Vector2:
	return node.get_global_transform_with_canvas().y.normalized()

## Returns a vector representing the local right direction of the given object
## Shorthand for node.transform.basis.x
static func get_local_right(node: Node) -> Vector2:
	return node.transform.basis.x.normalized()
## Returns a vector representing the local up direction of the given object
## Shorthand for node.transform.basis.y
static func get_local_up(node: Node) -> Vector2:
	return -node.transform.basis.y.normalized()
## Returns a vector representing the local left direction of the given object
## Shorthand for -node.transform.basis.x
static func get_local_left(node: Node) -> Vector2:
	return -node.transform.basis.x.normalized()
## Returns a vector representing the local down direction of the given object
## Shorthand for -node.transform.basis.y
static func get_local_down(node: Node) -> Vector2:
	return node.transform.basis.y.normalized()
