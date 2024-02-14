extends Node3D
## This script is intended to be added as a child of an object who is meant to float. The parent should be of type or inherits [RigidBody3D].
## All descendant [CollisionShape3D] objects will be used to determine where the surfaces of the object are to apply forces on.
## Reference: https://www.habrador.com/tutorials/unity-boat-tutorial/3-buoyancy/
class_name Buoyancy

## The world height of the water plane, if you'd like non-planar water then set getWaterDisplacementAt in script
@export var waterLevel: float = 0
## Returns the difference between the given point's height and the water height at that point as a float.
## If not set, will use the waterLevel variable.
# var getWaterDisplacementAt: Callable # Vector3 -> float

signal on_enter_water(obj: RigidBody3D)
signal on_exit_water(obj: RigidBody3D)

var _floater: RigidBody3D
var _freshly_underwater: bool = true

## Density of liquid
@export var rho: float = 150
## Should the triangle data be recalculated each time the object goes underwater
@export var recalculate_triangles_on_water_entry: bool = false
## Show debug data
@export var debug: bool = false
## Show bounds when debugging
@export var show_bounds: bool = false

# CollisionShape3D -> Array[Array[MeshHelpers.Triangle]]
# var _all_collider_data: Dictionary = {}
var _all_collider_data: Array[ColliderData] = []
# The total _bounds of the object to let us know when we have dipped under the water
var _bounds: AABB

class ColliderData:
	var collider: CollisionShape3D
	# Array[Array[MeshHelpers.Triangle]]
	var surfaces: Array

	func _init(col: CollisionShape3D, surf: Array):
		collider = col
		surfaces = surf
	
func _ready():
	_floater = NodeHelpers.get_parent_of_type(self, RigidBody3D)
	recalculate_triangle_data()
func _physics_process(_delta):
	var underwater = is_underwater()
	if debug:
		var collision_shapes = NodeHelpers.get_children_of_type(_floater, CollisionShape3D)
		DebugDraw.set_text(str(_floater, "_buoyancy"), str("is under water" if underwater else "is above water", " has ", collision_shapes.size(), " collider(s) with collider data for ", _all_collider_data.size()))
	if underwater:
		# each time we enter the water, recalculate our triangle data
		if _freshly_underwater:
			if recalculate_triangles_on_water_entry:
				recalculate_triangle_data()
			on_enter_water.emit(_floater)
		_freshly_underwater = false
		_apply_forces()
	else:
		if !_freshly_underwater:
			on_exit_water.emit(_floater)
		_freshly_underwater = true

func get_water_displacement_at(pos: Vector3) -> float:
	return pos.y - waterLevel
	# return getWaterDisplacementAt.call(pos) if getWaterDisplacementAt != null else pos.y - waterLevel

## Checks if the object is underwater using the y-positions of the corners of the bounds that encapsulates all the child colliders
func is_underwater():
	var global_up: Vector3 = NodeHelpers.get_global_up(_floater)
	var global_right: Vector3 = NodeHelpers.get_global_right(_floater)
	var global_forward: Vector3 = NodeHelpers.get_global_forward(_floater)
	var right_size = _bounds.size.x
	var up_size = _bounds.size.y
	var forward_size = _bounds.size.z

	var bottom_right_back = _floater.to_global(_bounds.position)
	var top_left_front = _floater.to_global(_bounds.end)

	var top_right_front = top_left_front + global_right * right_size
	var bottom_left_front = top_left_front - global_up * up_size
	var top_left_back = top_left_front - global_forward * forward_size

	var bottom_left_back = bottom_right_back - global_right * right_size
	var top_right_back = bottom_right_back + global_up * up_size
	var bottom_right_front = bottom_right_back + global_forward * forward_size

	var all_corners = [bottom_right_back, top_left_front, top_right_front, bottom_left_front, top_left_back, bottom_left_back, top_right_back, bottom_right_front]
	var result = false
	for corner in all_corners:
		if get_water_displacement_at(corner) < 0:
			result = true
			break
	if debug && show_bounds:
		var color = Color.BLUE
		for corner in all_corners:
			for other_corner in all_corners:
				if corner != other_corner:
					DebugDraw.draw_line_3d(corner, other_corner, color, 2)
	return result
## Recalculates the local triangle positions and their parents for future force application, make sure to call this whenever the object's shape changes
func recalculate_triangle_data():
	if debug:
		print_debug("Recalculating triangle data of ", _floater)
	_bounds = NodeHelpers.get_total_bounds_3d(_floater, true)
	_all_collider_data.clear()
	var collision_shapes = NodeHelpers.get_children_of_type(_floater, CollisionShape3D)
	for collider in collision_shapes:
		var collider_mesh = MeshHelpers.collision_shape_to_mesh(collider.shape)
		# prepare the array of arrays
		var surfaces = []
		for surface_index in collider_mesh.get_surface_count():
			var mesh_info = collider_mesh.surface_get_arrays(surface_index)
			var vertices: PackedVector3Array = mesh_info[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = mesh_info[Mesh.ARRAY_INDEX]
			var triangles: Array[MeshHelpers.Triangle] = []
			for i in range(0, indices.size(), 3):
				triangles.append(MeshHelpers.Triangle.new(vertices[indices[i]], vertices[indices[i + 1]], vertices[indices[i + 2]]))
			# append the current surface's array of triangles
			surfaces.append(triangles)
		_all_collider_data.append(ColliderData.new(collider, surfaces))
func _apply_forces():
	var gravity = PhysicsHelpers.get_gravity_3d()
	for collider_data in _all_collider_data:
		for triangle_data in collider_data.surfaces:
			for local_triangle in triangle_data:
				var triangle_center = collider_data.collider.to_global(local_triangle.center)
				# var triangle = MeshHelpers.Triangle.new(vert_a, vert_b, vert_c)
				if get_water_displacement_at(triangle_center) < 0:
					if debug:
						var vert_a = collider_data.collider.to_global(local_triangle.vertexA)
						var vert_b = collider_data.collider.to_global(local_triangle.vertexB)
						var vert_c = collider_data.collider.to_global(local_triangle.vertexC)
						DebugDraw.draw_line_3d(vert_a, vert_b, Color.GREEN, 2)
						DebugDraw.draw_line_3d(vert_b, vert_c, Color.GREEN, 2)
						DebugDraw.draw_line_3d(vert_a, vert_c, Color.GREEN, 2)
					var triangle_normal = collider_data.collider.to_global(local_triangle.normal) - collider_data.collider.global_position
					var force: Vector3 = rho * gravity.y * abs(get_water_displacement_at(triangle_center)) * local_triangle.area * triangle_normal
					force = Vector3(0, force.y, 0)
					_floater.apply_force(force, triangle_center - _floater.global_position)
