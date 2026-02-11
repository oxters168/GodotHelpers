@tool
extends Node3D
class_name Ocean

# because Area3D.SpaceOverride cannot be used as an enum for whatever reason (ex.: Area3D.SpaceOverride.keys())
enum SpaceOverride {
	SPACE_OVERRIDE_DISABLED, ## This area does not affect gravity/damping.
	SPACE_OVERRIDE_COMBINE, ## This area adds its gravity/damping values to whatever has been calculated so far (in priority order).
	SPACE_OVERRIDE_COMBINE_REPLACE, ## This area adds its gravity/damping values to whatever has been calculated so far (in priority order), ignoring any lower priority areas.
	SPACE_OVERRIDE_REPLACE, ## This area replaces any gravity/damping, even the defaults, ignoring any lower priority areas.
	SPACE_OVERRIDE_REPLACE_COMBINE, ## This area replaces any gravity/damping calculated so far (in priority order), but keeps calculating the rest of the areas.
}

## The target to follow
@export var target: Node3D

## How far to tile the ocean (1 => 3x3, 2 => 5x5, 3 => 7x7, ...)
@export var tile_distance: int = 1

## The tile_size of the plane mesh of each water tile
@export var tile_size: Vector2 = Vector2(20, 20)
	# set(new_size):
	# 	tile_size = new_size
	# 	_update_tiles(true)
## How far below the surface does the water affect objects
@export var water_depth: float = 50
	# set(new_water_depth):
	# 	water_depth = new_water_depth
	# 	_update_tiles(true)
## How much to subdivide the plane
@export var subdivide: Vector2i = Vector2i.ZERO
	# set(new_subdivide):
	# 	subdivide = new_subdivide
	# 	_update_tiles(true)
## Show debug data
@export var debug: bool = false
	# set(new_debug):
	# 	debug = new_debug
	# 	_update_tiles(true)

var linear_damp_space_override: Area3D.SpaceOverride = Area3D.SPACE_OVERRIDE_REPLACE:
	set(value):
		linear_damp_space_override = value
		notify_property_list_changed()
var linear_damp: float = 1.4
var angular_damp_space_override: Area3D.SpaceOverride = Area3D.SPACE_OVERRIDE_REPLACE:
	set(value):
		angular_damp_space_override = value
		notify_property_list_changed()
var angular_damp: float = 1.4

var _water_tiles: Array[WaterTile] = []

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append(PropertyHelpers.create_category_property("Linear Damp"))
	property_list.append(PropertyHelpers.create_enum_property(&"linear_damp_space_override", SpaceOverride.keys()))
	if linear_damp_space_override != SpaceOverride.SPACE_OVERRIDE_DISABLED:
		property_list.append(PropertyHelpers.create_float_property(&"linear_damp"))

	property_list.append(PropertyHelpers.create_category_property("Angular Damp"))
	property_list.append(PropertyHelpers.create_enum_property(&"angular_damp_space_override", SpaceOverride.keys()))
	if angular_damp_space_override != SpaceOverride.SPACE_OVERRIDE_DISABLED:
		property_list.append(PropertyHelpers.create_float_property(&"angular_damp"))
	return property_list
func _ready() -> void:
	if not Engine.is_editor_hint():
		_renew_tiles()
func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		_update_tiles(false)

func _renew_tiles() -> void:
	for water_tile in _water_tiles:
		remove_child(water_tile)
		water_tile.queue_free()
	_water_tiles.clear()

	var edge_count: int = tile_distance * 2 + 1
	for y in edge_count:
		for x in edge_count:
			var water_tile: WaterTile = WaterTile.new()
			add_child(water_tile)
			_water_tiles.append(water_tile)
	_update_tiles(true)

func _update_tiles(instant_jump: bool) -> void:
	var edge_count: int = tile_distance * 2 + 1
	var local_target_pos: Vector3 = (to_local(target.global_position) if target != null else position)
	var indexed_pos: Vector2i = _calculate_indexed_pos(local_target_pos, tile_size)
	var target_pos_offset: Vector3 = Vector3(indexed_pos.x * tile_size.x + tile_size.x / 2, 0, indexed_pos.y * tile_size.y + tile_size.y / 2)
	var good_indices: Dictionary[int, WaterTile] = {}
	var bad_tiles: Array[WaterTile] = []
	if debug:
		DebugDraw.set_text(str(self), indexed_pos)
	for y in edge_count:
		for x in edge_count:
			var index: int = y * edge_count + x
			var water_tile: WaterTile = _water_tiles[index]
			water_tile.size = tile_size
			water_tile.water_depth = water_depth
			water_tile.subdivide = subdivide
			water_tile.linear_damp_space_override = linear_damp_space_override
			water_tile.linear_damp = linear_damp
			water_tile.angular_damp_space_override = angular_damp_space_override
			water_tile.angular_damp = angular_damp
			water_tile.debug = debug
			var current_indexed_pos = _calculate_indexed_pos(water_tile.position, tile_size)
			if current_indexed_pos.x >= indexed_pos.x - tile_distance and current_indexed_pos.x <= indexed_pos.x + tile_distance and current_indexed_pos.y >= indexed_pos.y - tile_distance and current_indexed_pos.y <= indexed_pos.y + tile_distance:
				var indexed_diff: Vector2i = (current_indexed_pos - indexed_pos) + Vector2i(tile_distance, tile_distance)
				var new_index = indexed_diff.y * edge_count + indexed_diff.x
				good_indices[new_index] = water_tile
			else:
				bad_tiles.append(water_tile)
			if instant_jump:
				water_tile.position = Vector3(x * tile_size.x, 0, y * tile_size.y) - Vector3((tile_size.x * edge_count) / 2, 0, (tile_size.y * edge_count) / 2) + target_pos_offset
	if not instant_jump:
		# move the tiles already in the correct positions to their appropriate indices in the array
		for index in good_indices.keys():
			_water_tiles[index] = good_indices[index]
		# move the bad tiles both in the array and in the world
		for y in edge_count:
			for x in edge_count:
				var index: int = y * edge_count + x
				if not good_indices.keys().has(index):
					var water_tile: WaterTile = bad_tiles.pop_back()
					if water_tile:
						var new_position: Vector3 = Vector3(x * tile_size.x, 0, y * tile_size.y) - Vector3((tile_size.x * edge_count) / 2, 0, (tile_size.y * edge_count) / 2) + target_pos_offset
						water_tile.position = new_position
						_water_tiles[index] = water_tile
	
static func _calculate_indexed_pos(pos: Vector3, size: Vector2) -> Vector2i:
	return Vector2i(floori((pos.x + size.x / 2) / size.x), floori((pos.z + size.y / 2) / size.y))
