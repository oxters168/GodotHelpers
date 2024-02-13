class_name MeshHelpers

class Triangle:
	var vertexA: Vector3
	var vertexB: Vector3
	var vertexC: Vector3
	var center: Vector3
	var normal: Vector3
	var area: float

	func _init(_vertexA: Vector3, _vertexB: Vector3, _vertexC: Vector3):
		vertexA = _vertexA
		vertexB = _vertexB
		vertexC = _vertexC

		center = (vertexA + vertexB + vertexC) / 3
		normal = -(vertexB - vertexA).cross(vertexC - vertexA).normalized()

		var distanceAB: float = (vertexA - vertexB).length()
		var distanceAC: float = (vertexA - vertexC).length()
		area = (distanceAB * distanceAC * sin((vertexB - vertexA).angle_to(vertexC - vertexA))) / 2

## Converts the given [Shape3D] to a [Mesh]
static func collision_shape_to_mesh(shape: Shape3D, subdivide_width: int = 0, subdivide_height: int = 0, subdivide_depth: int = 0, radial_segments: int = 16, rings: int = 4) -> Mesh:
	# BoxShape3D, CapsuleShape3D, ConcavePolygonShape3D, ConvexPolygonShape3D, CylinderShape3D, HeightMapShape3D, SeparationRayShape3D, SphereShape3D, WorldBoundaryShape3D
	var final_mesh: Mesh
	if shape is BoxShape3D:
		var casted_shape = shape as BoxShape3D
		var largest_side = max(casted_shape.size.x, casted_shape.size.y, casted_shape.size.z)
		final_mesh = BoxMesh.new()
		final_mesh.size = casted_shape.size
		final_mesh.subdivide_width = subdivide_width
		final_mesh.subdivide_height = subdivide_height
		final_mesh.subdivide_depth = subdivide_depth
	elif shape is CapsuleShape3D:
		var casted_shape = shape as CapsuleShape3D
		final_mesh = CapsuleMesh.new()
		final_mesh.radius = casted_shape.radius
		final_mesh.height = casted_shape.height
		final_mesh.radial_segments = radial_segments
		final_mesh.rings = rings
	elif shape is CylinderShape3D:
		var casted_shape = shape as CylinderShape3D
		final_mesh = CylinderMesh.new()
		final_mesh.top_radius = casted_shape.radius
		final_mesh.bottom_radius = casted_shape.radius
		final_mesh.height = casted_shape.height
		final_mesh.radial_segments = radial_segments
		final_mesh.rings = rings
	elif shape is SphereShape3D:
		var casted_shape = shape as SphereShape3D
		final_mesh = SphereMesh.new()
		final_mesh.radius = casted_shape.radius
		final_mesh.height = casted_shape.radius * 2
		final_mesh.radial_segments = radial_segments
		final_mesh.rings = rings
	return final_mesh