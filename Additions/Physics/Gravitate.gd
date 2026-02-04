@tool
extends Node3D
## Place as a child of a [RigidBody3D] to make that body have their constant force modified to include a gravitational pull
## towards another [Node3D]
class_name Gravitate

enum CalculationMode {
    CONSTANT,        ## Applies an acceleration towards the target without taking into consideration the mass of the target nor its distance
    NEWTONIAN,       ## Calculates the force to be applied using Newton's law of universal gravitation
}

var gravity_mode: CalculationMode = CalculationMode.CONSTANT:
  set(new_mode):
    gravity_mode = new_mode
    notify_property_list_changed()

## The [Node3D] to gravitate towards, will gravitate to the global position of this object
var target: Node3D
## The acceleration with which to pull 
var acceleration: float = 9.8

## The [RigidBody3D] to gravitate towards, will gravitate towards the center of mass of this object
var other_body: RigidBody3D
## The constant (G) in the law of universal gravitation
var gravity_constant: float = 100

var _parent_body: RigidBody3D
var _prev_force: Vector3 = Vector3.ZERO

func _get_property_list():
  var property_list: Array = []
  property_list.append(PropertyHelpers.create_enum_property(&"gravity_mode", CalculationMode.keys()))

  match gravity_mode:
    CalculationMode.CONSTANT:
      property_list.append(PropertyHelpers.create_scene_object_property(&"target", &"Node3D"))
      property_list.append(PropertyHelpers.create_float_property(&"acceleration"))
    CalculationMode.NEWTONIAN:
      property_list.append(PropertyHelpers.create_scene_object_property(&"other_body", &"RigidBody3D"))

  return property_list

func _ready() -> void:
  if not Engine.is_editor_hint():
    _parent_body = NodeHelpers.get_parent_of_type(self, RigidBody3D)

func _physics_process(_delta: float) -> void:
  if not Engine.is_editor_hint():
    var force: Vector3 = Vector3.ZERO
    match gravity_mode:
      CalculationMode.CONSTANT:
        if target and _parent_body:
          var direction: Vector3 = (target.global_position - _parent_body.global_position).normalized()
          force = _parent_body.mass * acceleration * direction
      CalculationMode.NEWTONIAN:
        if target and _parent_body:
          var target_global_com: Vector3 = other_body.to_global(other_body.center_of_mass)
          var global_com: Vector3 = _parent_body.to_global(_parent_body.center_of_mass)
          var offset: Vector3 = target_global_com - global_com
          force = ((gravity_constant * other_body.mass * _parent_body.mass) / offset.length_squared()) * offset.normalized()

    _parent_body.constant_force -= _prev_force
    _parent_body.constant_force += force
    _prev_force = force
    DebugDraw.draw_line_3d(_parent_body.global_position, _parent_body.global_position + force, Color.GREEN)