@tool
extends BuoyantArea3D
class_name WaterTile

var _mesh_instance: MeshInstance3D
var _listening_collider: CollisionShape3D

## The size of the plane mesh
@export var size: Vector2 = Vector2(20, 20):
	set(new_size):
		size = new_size
		_refresh_plane()
		_refresh_area_3d()
## How far below the surface does the water affect objects
@export var water_depth: float = 50:
	set(new_water_depth):
		water_depth = new_water_depth
		_refresh_area_3d()
## How much to subdivide the plane
@export var subdivide: Vector2i = Vector2i.ZERO:
	set(new_subdivide):
		subdivide = new_subdivide
		_refresh_plane()

@export var simple_buoyancy: bool = true

@export_group("Water Material")
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

var _water_mat: ShaderMaterial

func _init():
	super._init()
	_water_mat = ShaderMaterial.new()
	_water_mat.shader = preload("../Shaders/ToonWater.gdshader")
	_water_mat.set_shader_parameter("surfaceNoise", preload("../Shaders/Resources/WaterPerlinNoise.png"))
	_water_mat.set_shader_parameter("distortNoise", preload("../Shaders/Resources/WaterDistortion.png"))

	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)
	var plane_mesh = PlaneMesh.new()
	plane_mesh.material = _water_mat
	_mesh_instance.mesh = plane_mesh
	_refresh_plane()
	
	var box_shape = BoxShape3D.new()
	_listening_collider = CollisionShape3D.new()
	_listening_collider.shape = box_shape
	add_child(_listening_collider)
	_refresh_area_3d()

func _process(_delta):
	if debug:
		DebugDraw.draw_box(_listening_collider.global_position, _listening_collider.shape.size, Color.YELLOW, 2)

func _refresh_area_3d():
	var box_shape = _listening_collider.shape as BoxShape3D
	box_shape.size = Vector3(size.x, water_depth, size.y)
	_listening_collider.position = NodeHelpers.get_local_down(self) * water_depth / 2
func _refresh_plane():
	_mesh_instance.mesh.size = size
	_mesh_instance.mesh.subdivide_width = subdivide.x
	_mesh_instance.mesh.subdivide_depth = subdivide.y

func is_point_submerged(point: Vector3) -> bool:
	if simple_buoyancy:
		return point.y < global_position.y
	else:
		return super.is_point_submerged(point)
func get_submerged_displacement(point: Vector3) -> Vector3:
	if simple_buoyancy:
		return Vector3(0, global_position.y - point.y, 0)
	else:
		return super.get_submerged_displacement(point)