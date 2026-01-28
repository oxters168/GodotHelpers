extends MeshInstance3D
## Used as reference: https://www.habrador.com/tutorials/unity-boat-tutorial/3-buoyancy/
class_name WaterTile

var _plane_mesh: PlaneMesh
var _listening_collider: CollisionShape3D

## The size of the plane mesh
@export var size: Vector2 = Vector2(20, 20):
	set(new_size):
		size = new_size
		_refresh_plane()
		_refresh_area_3d()
## How much to subdivide the plane
@export var subdivide: Vector2i = Vector2i.ZERO:
	set(new_subdivide):
		subdivide = new_subdivide
		_refresh_plane()

@export_group("Details")
@export var beer_factor: float = 0.8:
	set(new_beer_factor):
		beer_factor = new_beer_factor
		_water_mat.set_shader_parameter("beer_factor", beer_factor)

@export var foam_distance: float = 0.01:
	set(new_foam_distance):
		foam_distance = new_foam_distance
		_water_mat.set_shader_parameter("foam_distance", foam_distance)
@export var foam_max_distance: float = 0.4:
	set(new_foam_max_distance):
		foam_max_distance = new_foam_max_distance
		_water_mat.set_shader_parameter("foam_max_distance", foam_max_distance)
@export var foam_min_distance: float = 0.04:
	set(new_foam_min_distance):
		foam_min_distance = new_foam_min_distance
		_water_mat.set_shader_parameter("foam_min_distance", foam_min_distance)
@export var foam_color: Color = Color.WHITE:
	set(new_foam_color):
		foam_color = new_foam_color
		_water_mat.set_shader_parameter("foam_color", foam_color)
@export_range(0, 1) var opaque: float = 0:
	set(new_opaque):
		opaque = new_opaque
		_water_mat.set_shader_parameter("opaque", opaque)

@export var surface_noise_tiling: Vector2 = Vector2(1.0, 4.0):
	set(new_surface_noise_tiling):
		surface_noise_tiling = new_surface_noise_tiling
		_water_mat.set_shader_parameter("surface_noise_tiling", surface_noise_tiling)
@export var surface_noise_scroll: Vector3 = Vector3(0.03, 0.03, 0.0):
	set(new_surface_noise_scroll):
		surface_noise_scroll = new_surface_noise_scroll
		_water_mat.set_shader_parameter("surface_noise_scroll", surface_noise_scroll)
@export_range(0, 1) var surface_noise_cutoff: float = 0.777:
	set(new_surface_noise_cutoff):
		surface_noise_cutoff = new_surface_noise_cutoff
		_water_mat.set_shader_parameter("surface_noise_cutoff", surface_noise_cutoff)
@export_range(0, 1) var surface_distortion_amount: float = 0.27:
	set(new_surface_distortion_amount):
		surface_distortion_amount = new_surface_distortion_amount
		_water_mat.set_shader_parameter("surface_distortion_amount", surface_distortion_amount)

@export_group("Physics")
## Should this water tile apply buoyancy forces to any physics objects that fall in
@export var apply_buoyancy: bool = false
## Density of liquid
@export var rho: float = 150
## How far below the surface does the water affect objects
@export var water_depth: float = 50:
	set(new_water_depth):
		water_depth = new_water_depth
		_refresh_area_3d()
## Show debug data
@export var debug: bool = false

var _water_mat: ShaderMaterial
## Node3D -> Array[WaterTile] (only the first water tile in the array processes the given floater)
static var _current_floaters: Dictionary = {}
## CollisionObject3D -> Dictionary<CollisionShape3D, Array[Array[MeshHelpers.Triangle]]>
static var _floater_cache: Dictionary = {}

func _init():
	_water_mat = ShaderMaterial.new()
	_water_mat.shader = preload("../Shaders/ToonWater.gdshader")
	_water_mat.set_shader_parameter("surfaceNoise", preload("../Shaders/Resources/WaterPerlinNoise.png"))
	_water_mat.set_shader_parameter("distortNoise", preload("../Shaders/Resources/WaterDistortion.png"))

	_plane_mesh = PlaneMesh.new()
	_plane_mesh.material = _water_mat
	_refresh_plane()
	
	var area_3d = Area3D.new()
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	add_child(area_3d)
	var box_shape = BoxShape3D.new()
	_listening_collider = CollisionShape3D.new()
	_listening_collider.shape = box_shape
	area_3d.add_child(_listening_collider)
	_refresh_area_3d()

	mesh = _plane_mesh
func _physics_process(_delta):
	if apply_buoyancy:
		_process_buoyancy()

func _process_buoyancy():
	var processed_floater: bool = false
	var gravity: Vector3 = PhysicsHelpers.get_gravity_3d()
	for floating_obj in _current_floaters.keys():
		# if an object was intersected with and we are the water tile in charge of applying forces to it
		if _current_floaters[floating_obj][0] == self:
			processed_floater = true
			# if this object has not been seen yet then cache its children who will be used to calculate how buoyancy will affect it
			if !_floater_cache.has(floating_obj):
				# _floater_cache[floating_obj] = FloaterData.new(NodeHelpers.get_children_of_type(floating_obj, MeshInstance3D))
				var collision_shapes = NodeHelpers.get_children_of_type(floating_obj, CollisionShape3D)
				var colliders_dict: Dictionary = {}
				# for each collision shape, create a corresponding mesh
				for collision_shape in collision_shapes:
					var meshed_shape = MeshHelpers.collision_shape_to_mesh(collision_shape.shape)
					if meshed_shape != null:
						colliders_dict[collision_shape] = []
						for surface_id in meshed_shape.get_surface_count():
							var surface_data = meshed_shape.surface_get_arrays(surface_id)
							var vertices = surface_data[Mesh.ARRAY_VERTEX]
							var indices = surface_data[Mesh.ARRAY_INDEX]
							var triangles: Array[MeshHelpers.Triangle] = []
							for i in range(0, indices.size(), 3):
								triangles.append(MeshHelpers.Triangle.new(vertices[indices[i]], vertices[indices[i + 1]], vertices[indices[i + 2]]))
							colliders_dict[collision_shape].append(triangles)
				_floater_cache[floating_obj] = colliders_dict
			var floater_data: Dictionary = _floater_cache[floating_obj]
			if debug:
				DebugDraw.set_text(str(floating_obj, "_buoyancy"), str(floater_data.size(), " collider(s) ", " processed by ", self))
			for collision_shape in floater_data.keys():
				for triangles in floater_data[collision_shape]:
					for local_triangle in triangles:
						var triangle_center = collision_shape.to_global(local_triangle.center)
						if get_water_displacement_at(triangle_center) < 0:
							if debug:
								var vert_a = collision_shape.to_global(local_triangle.vertexA)
								var vert_b = collision_shape.to_global(local_triangle.vertexB)
								var vert_c = collision_shape.to_global(local_triangle.vertexC)
								DebugDraw.draw_line_3d(vert_a, vert_b, Color.GREEN, 2)
								DebugDraw.draw_line_3d(vert_b, vert_c, Color.GREEN, 2)
								DebugDraw.draw_line_3d(vert_a, vert_c, Color.GREEN, 2)
								# DebugDraw.draw_ray_3d(triangle.center, triangle.normal, 1, Color.BLUE, 2)
							# TODO: Make force work with any gravity orientation, not just the assumed up direction
							# print_debug(rho, " * ", gravity.y, " * ", abs(get_water_displacement_at(triangle.center)), " * ", triangle.area, " * ", triangle.normal)
							var triangle_normal = collision_shape.global_transform * local_triangle.normal
							var force: Vector3 = rho * gravity.y * -get_water_displacement_at(triangle_center) * local_triangle.area * triangle_normal
							force = Vector3(0, force.y, 0)
							floating_obj.apply_force(force, floating_obj.to_local(triangle_center))
	if debug:
		DebugDraw.draw_box(_listening_collider.global_position, _listening_collider.shape.size, Color.GREEN if processed_floater else Color.RED, 2)

func _on_body_entered(body: Node3D):
	if _current_floaters.has(body):
		_current_floaters[body].append(self)
	else:
		_current_floaters[body] = [self]
func _on_body_exited(body: Node3D):
	if _current_floaters[body].size() > 1:
		_current_floaters[body].erase(self)
	else:
		_current_floaters.erase(body)

func get_water_displacement_at(pos: Vector3) -> float:
	return pos.y - global_position.y

func _refresh_area_3d():
	var box_shape = _listening_collider.shape as BoxShape3D
	box_shape.size = Vector3(size.x, water_depth, size.y)
	_listening_collider.position = NodeHelpers.get_local_down(self) * water_depth / 2
func _refresh_plane():
	_plane_mesh.size = size
	_plane_mesh.subdivide_width = subdivide.x
	_plane_mesh.subdivide_depth = subdivide.y
