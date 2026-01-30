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

## Checks whether a point whose origin is Vector3.ZERO is within a box centered at that origin with the given size
static func is_pos_in_box(local_position: Vector3, size: Vector3) -> bool:
	return abs(local_position.x) <= size.x / 2 and abs(local_position.y) <= size.y / 2 and abs(local_position.z) <= size.z / 2
## Calculates the local vector needed to reach the surface of a box whose center is Vector3.ZERO and has the given size from the given local position
static func point_to_surface_of_box(local_position: Vector3, size: Vector3) -> Vector3:
	var right_dist: float = abs(size.x / 2 - local_position.x)
	var left_dist: float = abs(-size.x / 2 - local_position.x)
	var top_dist: float = abs(size.y / 2 - local_position.y)
	var bot_dist: float = abs(-size.y / 2 - local_position.y)
	var front_dist: float = abs(-size.z / 2 - local_position.z)
	var back_dist: float = abs(size.z / 2 - local_position.z)
	# if closest surface is the right surface
	if right_dist < left_dist and right_dist < front_dist and right_dist < back_dist and right_dist < top_dist and right_dist < bot_dist:
		var surface_in_direction: Vector3 = Vector3(
			size.x / 2,
			sign(local_position.y) * min(abs(local_position.y), size.y / 2),
			sign(local_position.z) * min(abs(local_position.z), size.z / 2)
		)
		return surface_in_direction - local_position
	# if closest surface is the left surface
	elif left_dist < right_dist and left_dist < front_dist and left_dist < back_dist and left_dist < top_dist and left_dist < bot_dist:
		var surface_in_direction: Vector3 = Vector3(
			-size.x / 2,
			sign(local_position.y) * min(abs(local_position.y), size.y / 2),
			sign(local_position.z) * min(abs(local_position.z), size.z / 2)
		)
		return surface_in_direction - local_position
	# if closest surface is the top surface
	elif top_dist < bot_dist and top_dist < front_dist and top_dist < back_dist and top_dist < right_dist and top_dist < left_dist:
		var surface_in_direction: Vector3 = Vector3(
			sign(local_position.x) * min(abs(local_position.x), size.x / 2),
			size.y / 2,
			sign(local_position.z) * min(abs(local_position.z), size.z / 2)
		)
		return surface_in_direction - local_position
	# if closest surface is the bottom surface
	elif bot_dist < top_dist and bot_dist < front_dist and bot_dist < back_dist and bot_dist < right_dist and bot_dist < left_dist:
		var surface_in_direction: Vector3 = Vector3(
			sign(local_position.x) * min(abs(local_position.x), size.x / 2),
			-size.y / 2,
			sign(local_position.z) * min(abs(local_position.z), size.z / 2)
		)
		return surface_in_direction - local_position
	# if closest surface is the front surface
	elif front_dist < back_dist and front_dist < right_dist and front_dist < left_dist and front_dist < top_dist and front_dist < bot_dist:
		var surface_in_direction: Vector3 = Vector3(
			sign(local_position.x) * min(abs(local_position.x), size.x / 2),
			sign(local_position.y) * min(abs(local_position.y), size.y / 2),
			-size.z / 2
		)
		return surface_in_direction - local_position
	# if closest surface is the back surface
	else:
		var surface_in_direction: Vector3 = Vector3(
			sign(local_position.x) * min(abs(local_position.x), size.x / 2),
			sign(local_position.y) * min(abs(local_position.y), size.y / 2),
			size.z / 2
		)
		return surface_in_direction - local_position
## Checks whether the given point is within the given collision shape (currently only supports [BoxShape3D], [CapsuleShape3D], [CylinderShape3D], [SphereShape3D], [ConvexPolygonShape3D])
static func is_point_in_collision_shape(collision_shape: CollisionShape3D, pos: Vector3, is_global: bool = true) -> bool:
	var local_position = collision_shape.to_local(pos) if is_global else pos
	if collision_shape.shape is BoxShape3D:
		var casted_shape = collision_shape.shape as BoxShape3D
		if is_pos_in_box(local_position, casted_shape.size):
			return true
	elif collision_shape.shape is CapsuleShape3D:
		var casted_shape = collision_shape.shape as CapsuleShape3D
		if Vector2(local_position.x, local_position.z).length_squared() <= casted_shape.radius * casted_shape.radius:
			if abs(local_position.y) <= (casted_shape.mid_height / 2):
				return true
			elif local_position.y > 0 and (local_position - Vector3(0, casted_shape.mid_height / 2, 0)).length_squared() <= casted_shape.radius * casted_shape.radius:
				return true
			elif local_position.y < 0 and (local_position - Vector3(0, -casted_shape.mid_height / 2, 0)).length_squared() <= casted_shape.radius * casted_shape.radius:
				return true
	elif collision_shape.shape is CylinderShape3D:
		var casted_shape = collision_shape.shape as CylinderShape3D
		if Vector2(local_position.x, local_position.z).length_squared() <= casted_shape.radius * casted_shape.radius and abs(local_position.y) <= casted_shape.height / 2:
			return true
	elif collision_shape.shape is SphereShape3D:
		var casted_shape = collision_shape.shape as SphereShape3D
		if local_position.length_squared() <= casted_shape.radius * casted_shape.radius:
			return true
	elif collision_shape.shape is ConvexPolygonShape3D:
		var casted_shape = collision_shape.shape as ConvexPolygonShape3D
		var size = MeshHelpers.calculate_size_from_points(casted_shape.points)
		if is_pos_in_box(local_position, size):
			return true
	else:
		printerr("Provided collision shape not currently supported ", typeof(collision_shape))
	return false
## Calculates the global vector needed to reach the surface of the given collision shape from the given position
## (currently only supports [BoxShape3D], [CapsuleShape3D], [CylinderShape3D], [SphereShape3D], [ConvexPolygonShape3D])
static func point_to_surface_of_collision_shape(collision_shape: CollisionShape3D, pos: Vector3, is_global: bool = true) -> Vector3:
	var local_position = collision_shape.to_local(pos) if is_global else pos
	if collision_shape.shape is BoxShape3D:
		var casted_shape = collision_shape.shape as BoxShape3D
		return collision_shape.global_basis * point_to_surface_of_box(local_position, casted_shape.size)
	elif collision_shape.shape is CapsuleShape3D:
		var casted_shape = collision_shape.shape as CapsuleShape3D
		if abs(local_position.y) <= (casted_shape.mid_height / 2):
			var xz_vector: Vector3 = Vector3(local_position.x, 0, local_position.z)
			var surface_in_direction: Vector3 = xz_vector.normalized() * casted_shape.radius
			return collision_shape.global_basis * (surface_in_direction - xz_vector)
		elif local_position.y > 0:
			var top_center: Vector3 = Vector3(0, casted_shape.mid_height / 2, 0)
			var shifted_origin: Vector3 = local_position - top_center
			var surface_in_direction: Vector3 = shifted_origin.normalized() * casted_shape.radius
			return collision_shape.global_basis * (surface_in_direction - shifted_origin)
		else:
			var bot_center: Vector3 = Vector3(0, -casted_shape.mid_height / 2, 0)
			var shifted_origin: Vector3 = local_position - bot_center
			var surface_in_direction: Vector3 = shifted_origin.normalized() * casted_shape.radius
			return collision_shape.global_basis * (surface_in_direction - shifted_origin)
	elif collision_shape.shape is CylinderShape3D:
		var casted_shape = collision_shape.shape as CylinderShape3D
		var xz_vector: Vector3 = Vector3(local_position.x, 0, local_position.z)
		var side_surface_in_dir: Vector3 = xz_vector.normalized() * casted_shape.radius
		var side_surface_vector: Vector3 = (side_surface_in_dir - xz_vector) + Vector3(0, sign(local_position.y) * min(abs(local_position.y), casted_shape.height / 2) - local_position.y, 0)
		if xz_vector.length_squared() <= casted_shape.radius * casted_shape.radius:
			if local_position.y > 0:
				var top_surface_in_dir: Vector3 = xz_vector + Vector3(0, casted_shape.height / 2, 0)
				var top_surface_vector: Vector3 = top_surface_in_dir - local_position
				return collision_shape.global_basis * (top_surface_vector if top_surface_vector.length_squared() < side_surface_vector.length_squared() else side_surface_vector)
			else:
				var bot_surface_in_dir: Vector3 = xz_vector + Vector3(0, -casted_shape.height / 2, 0)
				var bot_surface_vector: Vector3 = bot_surface_in_dir - local_position
				return collision_shape.global_basis * (bot_surface_vector if bot_surface_vector.length_squared() < side_surface_vector.length_squared() else side_surface_vector)
		return collision_shape.global_basis * side_surface_vector
	elif collision_shape.shape is SphereShape3D:
		var casted_shape = collision_shape.shape as SphereShape3D
		var surface_in_direction: Vector3 = local_position.normalized() * casted_shape.radius
		return collision_shape.global_basis * (surface_in_direction - local_position)
	elif collision_shape.shape is ConvexPolygonShape3D:
		var casted_shape = collision_shape.shape as ConvexPolygonShape3D
		var size = MeshHelpers.calculate_size_from_points(casted_shape.points)
		return collision_shape.global_basis * point_to_surface_of_box(local_position, size)
	else:
		printerr("Provided collision shape not currently supported ", typeof(collision_shape))
	return Vector3.ZERO

## Calculates the bounding box size of the given points so long as their origin is (0, 0, 0)
static func calculate_size_from_points(points: PackedVector3Array) -> Vector3:
	var smallest_values: Vector3 = Vector3.ZERO
	var largest_values: Vector3 = Vector3.ZERO
	for point in points:
		if point.x > largest_values.x: largest_values.x = point.x
		if point.y > largest_values.y: largest_values.y = point.y
		if point.z > largest_values.z: largest_values.z = point.z
		if point.x < smallest_values.x: smallest_values.x = point.x
		if point.y < smallest_values.y: smallest_values.y = point.y
		if point.z < smallest_values.z: smallest_values.z = point.z
	return largest_values - smallest_values

## Converts the given [Shape3D] to a [Mesh] (currently only supports [BoxShape3D], [CapsuleShape3D], [CylinderShape3D], [SphereShape3D], [ConvexPolygonShape3D])
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
