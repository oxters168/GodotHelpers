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
	elif shape is ConvexPolygonShape3D:
		var casted_shape = shape as ConvexPolygonShape3D
		final_mesh = create_mesh_from_convex_shape(casted_shape)
	return final_mesh

## Converts the given [PackedVector3Array] representing a convex hull to an [ArrayMesh] with normals and indices
static func create_mesh_from_convex_hull(vertices: PackedVector3Array) -> ArrayMesh:
	var convex_shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	convex_shape.points = vertices
	return create_mesh_from_convex_shape(convex_shape)
# written by claude 4.5
## Converts the given [ConvexPolygonShape3D] to an [ArrayMesh] with normals and indices
static func create_mesh_from_convex_shape(convex_shape: ConvexPolygonShape3D) -> ArrayMesh:
	# Get the faces (each face is a triangle with 3 vertex indices)
	var faces = convex_shape.get_debug_mesh().generate_triangle_mesh().get_faces()
	
	# Prepare mesh arrays
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var mesh_vertices = PackedVector3Array()
	var mesh_normals = PackedVector3Array()
	var mesh_indices = PackedInt32Array()
	
	# Process faces (groups of 3 vertices)
	for i in range(0, faces.size(), 3):
		var v1 = faces[i]
		var v2 = faces[i + 1]
		var v3 = faces[i + 2]
		
		# Calculate face normal
		var edge1 = v2 - v1
		var edge2 = v3 - v1
		var normal = edge1.cross(edge2).normalized()
		
		# Add vertices and normals
		var base_index = mesh_vertices.size()
		mesh_vertices.append(v1)
		mesh_vertices.append(v2)
		mesh_vertices.append(v3)
		
		mesh_normals.append(normal)
		mesh_normals.append(normal)
		mesh_normals.append(normal)
		
		# Add indices
		mesh_indices.append(base_index)
		mesh_indices.append(base_index + 1)
		mesh_indices.append(base_index + 2)
	
	arrays[Mesh.ARRAY_VERTEX] = mesh_vertices
	arrays[Mesh.ARRAY_NORMAL] = mesh_normals
	arrays[Mesh.ARRAY_INDEX] = mesh_indices
	
	# Create the mesh
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh

## Returns a MeshInstance3D object whose mesh is a box with the given size and material
static func create_box_3d(size: Vector3 = Vector3.ONE, mat: Material = null) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	box.mesh = box_mesh
	box.material_override = mat
	return box
## Returns a MeshInstance3D object whose mesh is a sphere with the given radius, height, and material
static func create_sphere_3d(radius: float = 0.5, height: float = 1, mat: Material = null) -> MeshInstance3D:
	var sphere := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = height
	sphere.mesh = sphere_mesh
	sphere.material_override = mat
	return sphere
