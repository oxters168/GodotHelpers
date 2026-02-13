@tool
extends RigidBody3D
class_name Car

@export var wheels: Array[Wheel3D]

## The maximum speed the car can travel in meters per second
@export var max_speed: float = 30
## The acceleration of the car in meters per second squared
@export var acceleration: float = 10
## The deceleration of the car in meters per second squared
@export var deceleration: float = 2
## The maximum angle a wheel can rotate in radians
@export var max_steer_angle: float = PI / 4
## The speed a wheel reaches the steer angle in radians per second
@export var steer_speed: float = PI / 2
## How much percent acceleration the wheel should have, represented by the y-axis, in relation to
## the percent max velocity it currently has, represented by the x-axis
@export var accel_curve: Curve = preload("res://godot_helpers/Additions/Examples/CarPhysics/default_accel_curve.tres")

## Info on occupying and being occupied
@export var occupant_info: IOccupy = preload("res://godot_helpers/Additions/Physics/Vehicles/Extras/sedan_sports_occupant_info.tres")

## Whether to show debug info
@export var debug: bool = false

## A [Vector2] that is not normalized but the values are clamped between -1 and 1 where the x value
## represents the steer input and the y value represents the gas input
var input_vector: Vector2 = Vector2.ZERO:
	set(value):
		input_vector = Vector2(clampf(value.x, -1, 1), clampf(value.y, -1, 1))

func _ready() -> void:
	if not Engine.is_editor_hint():
		add_child(Vehicle.new(self))
		if wheels:
			for wheel in wheels:
				wheel.add_exception(get_rid())

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		Vehicle._draw_exit_spots(self, occupant_info)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		# var input_vector: Vector2 = Vector2(Input.get_axis("move_hor_neg", "move_hor_pos"), Input.get_axis("move_ver_neg", "move_ver_pos"))
		var velocity: float = NodeHelpers.get_global_forward(self).dot(linear_velocity)
		if debug:
			DebugDraw.set_text(str(self), str("velocity: ", velocity))
		if wheels:
			for wheel: Wheel3D in wheels:
				wheel.debug = debug
				var force: Vector3 = wheel.calculate_force_on_vehicle(self, input_vector, delta)
				apply_force(force, wheel.global_position - global_position)

func get_wheel_count() -> int:
	return wheels.size() if wheels else 0
func get_total_steer_coefficient() -> float:
	return wheels.reduce(func(accum: float, wheel: Wheel3D): return accum + abs(wheel.steer_coefficient), 0)
