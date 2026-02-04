@tool
extends Node3D
class_name Circle3D

## The radius of the circle
@export var radius: float = 1:
  set(value):
    radius = value
    _redraw()
## How many lines make up the circle
@export_range(5, 64) var detail: int = 32:
  set(value):
    detail = value
    _redraw()

var _immediate_geometry: ImmediateMesh

func _init() -> void:
  var mesh_instance: MeshInstance3D = MeshInstance3D.new()
  _immediate_geometry = ImmediateMesh.new()
  mesh_instance.mesh = _immediate_geometry
  add_child(mesh_instance)
  _redraw()

func _redraw() -> void:
  _immediate_geometry.clear_surfaces()
  _immediate_geometry.surface_begin(Mesh.PRIMITIVE_LINES)
  
  var angle_offset: float = (PI * 2) / detail
  for i in range(detail):
    var angle: float = angle_offset * i
    var next_angle: float = angle_offset * (0 if i >= detail - 1 else (i + 1))
    var start: Vector3 = Vector3(sin(angle) * radius, cos(angle) * radius, 0)
    var end: Vector3 = Vector3(sin(next_angle) * radius, cos(next_angle) * radius, 0)
    _immediate_geometry.surface_set_color(Color.BLUE)
    _immediate_geometry.surface_add_vertex(start)
    _immediate_geometry.surface_add_vertex(end)    
    
  _immediate_geometry.surface_end()