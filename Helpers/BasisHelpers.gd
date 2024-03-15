class_name BasisHelpers

## Converts a basis from the local space of the parent to a basis in the same space the parent is currently in
static func to_global(parent_global_basis: Basis, local_basis: Basis) -> Basis:
	return parent_global_basis * local_basis
## Converts a basis existing in the same space as the parent into a basis in the local space of the parent
static func to_local(parent_global_basis: Basis, global_basis: Basis) -> Basis:
	return parent_global_basis.inverse() * global_basis

## Returns a vector representing the right direction of the given basis.
## Shorthand for -basis.x.normalized()
static func get_right(basis: Basis) -> Vector3:
	return -basis.x.normalized()
## Returns a vector representing the up direction of the given basis.
## Shorthand for basis.y.normalized()
static func get_up(basis: Basis) -> Vector3:
	return basis.y.normalized()
## Returns a vector representing the forward direction of the given basis.
## Shorthand for basis.z.normalized()
static func get_forward(basis: Basis) -> Vector3:
	return basis.z.normalized()
## Returns a vector representing the left direction of the given basis.
## Shorthand for basis.x.normalized()
static func get_left(basis: Basis) -> Vector3:
	return basis.x.normalized()
## Returns a vector representing the down direction of the given basis.
## Shorthand for -basis.y.normalized()
static func get_down(basis: Basis) -> Vector3:
	return -basis.y.normalized()
## Returns a vector representing the back direction of the given basis.
## Shorthand for -basis.z.normalized()
static func get_back(basis: Basis) -> Vector3:
	return -basis.z.normalized()