@tool
extends Node3D
class_name PointWithinCollisionShapeExample

@export var target: Node3D
@export var collision_shapes: Array[CollisionShape3D]

func _process(delta: float) -> void:
  # print("running")
  if collision_shapes and target:
    for collision_shape in collision_shapes:
      if collision_shape:
        var color: Color = Color.GREEN if MeshHelpers.is_point_in_collision_shape(collision_shape, target.global_position) else Color.RED
        collision_shape.debug_color = color
        DebugDraw.draw_line_3d(
          target.global_position,
          target.global_position + MeshHelpers.point_to_surface_of_collision_shape(collision_shape, target.global_position),
          color
        )
