@tool
extends Area3D
## Pushes back on gravity + constant force applied to any rigidbody that falls into this[br]
## Used as reference: https://www.habrador.com/tutorials/unity-boat-tutorial/3-buoyancy/
class_name BuoyantArea3D

## Density of liquid
@export var rho: float = 150
## Show debug data
@export var debug: bool = false:
  set(new_debug):
    debug = new_debug
    for collision_shape in NodeHelpers.get_children_of_type(self, CollisionShape3D):
      collision_shape.debug_fill = new_debug

## Node3D -> Array[BuoyantArea3D] (only the first water tile in the array processes the given floater)
static var _current_floaters: Dictionary[Node3D, Array] = {}
## CollisionObject3D -> Dictionary[CollisionShape3D, Array[Array[MeshHelpers.Triangle]]]
static var _floater_cache: Dictionary[CollisionObject3D, Dictionary] = {}

var _collision_shapes: Array[CollisionShape3D] = []

func _init() -> void:
  if not Engine.is_editor_hint():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _ready() -> void:
  if not Engine.is_editor_hint():
    _collision_shapes.append_array(NodeHelpers.get_children_of_type(self, CollisionShape3D))
  else:
    linear_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
    linear_damp = 2
    angular_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
    angular_damp = 2


func _physics_process(_delta):
  if not Engine.is_editor_hint():
    _process_buoyancy()

func _process_buoyancy():
  for floating_obj in _current_floaters.keys():
    # if an object was intersected with and we are the water tile in charge of applying forces to it
    if _current_floaters[floating_obj][0] == self:
      # processed_floater = true
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
      for floater_collision_shape: CollisionShape3D in floater_data.keys():
        for triangles in floater_data[floater_collision_shape]:
          for local_triangle in triangles:
            var triangle_center = floater_collision_shape.to_global(local_triangle.center)
            # if submerged
            if is_point_submerged(triangle_center):
              if debug:
                var vert_a = floater_collision_shape.to_global(local_triangle.vertexA)
                var vert_b = floater_collision_shape.to_global(local_triangle.vertexB)
                var vert_c = floater_collision_shape.to_global(local_triangle.vertexC)
                DebugDraw.draw_line_3d(vert_a, vert_b, Color.GREEN, 2)
                DebugDraw.draw_line_3d(vert_b, vert_c, Color.GREEN, 2)
                DebugDraw.draw_line_3d(vert_a, vert_c, Color.GREEN, 2)
                # DebugDraw.draw_ray_3d(triangle.center, triangle.normal, 1, Color.BLUE, 2)
              # TODO: Make force work with any gravity orientation, not just the assumed up direction
              # print_debug(rho, " * ", gravity.y, " * ", abs(get_water_displacement_at(triangle.center)), " * ", triangle.area, " * ", triangle.normal)
              var triangle_normal = floater_collision_shape.global_basis * local_triangle.normal
              var submerged_displacement: Vector3 = get_submerged_displacement(triangle_center)
              var floater_body: RigidBody3D = NodeHelpers.get_parent_of_type(floater_collision_shape, RigidBody3D)
              var gravity_strength: float = floater_body.get_gravity().dot(submerged_displacement.normalized())
              var constant_force_strength: float = floater_body.constant_force.dot(submerged_displacement.normalized())
              var force: Vector3 = rho * min(gravity_strength + constant_force_strength, -1) * submerged_displacement * local_triangle.area * triangle_normal
              if debug:
                DebugDraw.draw_line_3d(triangle_center, triangle_center + force, Color.BLUE)
              floating_obj.apply_force(force, floating_obj.to_local(triangle_center))

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

func is_point_submerged(point: Vector3) -> bool:
  return get_collision_shape_containing_pos(point) != null
func get_submerged_displacement(point: Vector3) -> Vector3:
  var area_collision_shape: CollisionShape3D = get_collision_shape_containing_pos(point)
  return MeshHelpers.point_to_surface_of_collision_shape(area_collision_shape, point)
func get_collision_shape_containing_pos(pos: Vector3) -> CollisionShape3D:
  for collision_shape in _collision_shapes:
    if MeshHelpers.is_point_in_collision_shape(collision_shape, pos):
      return collision_shape
  return null