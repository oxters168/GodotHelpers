@tool
extends Node3D
## Wheel physics based on this youtube video by Toyful Games
## https://youtu.be/CdPYlj5uZeI?si=iQMB-u82wBhdgD-X
class_name Wheel3D

## The visual representation of the wheel
@export var wheel_visual: Node3D
## The distance to the wheel from the suspension in meters if no force was being applied
@export var suspension_rest_dist: float = 0.4
## The strength of the spring
@export var spring_strength: float = 20
## The amount of dampening strength the spring has
@export var spring_damper: float = 0.5
## The radius of the wheel in meters
@export var wheel_radius: float = 0.3
## The thickness of the wheel in meters
@export var wheel_thickness: float = 0.1
## The multiplier on the steer angle of the wheel when the angle is set (applied after clamping)
@export_range(0, 1) var steer_coefficient: float = 1
## The percent force this wheel has to drive from the acceleration of the wheelable vehicle
@export_range(0, 1) var drive_percent: float = 0.25
## How much percent slip the wheel resists, represented by the y-axis, in relation to the percent
## velocity it currently has along the slip direction, represented by the x-axis
@export var friction_curve: Curve

@export_category("Debug")
@export var debug: bool = false
@export var debug_ray_scale: float = 2

var _raycast: RayCast3D
var _current_angle: float = 0
var _current_ground_dist: float = wheel_radius

var _prev_wheel_forward: Vector3
var _prev_wheel_right: Vector3
var _prev_roll_velocity: float = 0

func _init() -> void:
	if not Engine.is_editor_hint():
		_raycast = RayCast3D.new()
		_raycast.target_position = Vector3.DOWN * suspension_rest_dist
		add_child(_raycast)
func _ready() -> void:
	if not Engine.is_editor_hint():
		_prev_wheel_forward = NodeHelpers.get_global_forward(self)
		_prev_wheel_right = NodeHelpers.get_global_right(self)

func _process(_delta: float) -> void:
	var wheel_up: Vector3 = NodeHelpers.get_global_up(self)
	if debug:
		DebugDraw.draw_circle_3d(global_position - wheel_up * (_current_ground_dist - wheel_radius), global_basis.rotated(wheel_up, (PI / 2) + _current_angle).get_rotation_quaternion(), wheel_radius)
		DebugDraw.draw_ray_3d(global_position, -wheel_up, suspension_rest_dist)
		# DebugDraw.draw_ray_3d(global_position, -wheel_up, _current_ground_dist, Color.YELLOW)
	if wheel_visual:
		wheel_visual.position = Vector3.DOWN * (_current_ground_dist - wheel_radius)
		wheel_visual.rotation = Vector3.UP * _current_angle

func calculate_force_on_vehicle(car: Car, input_vector: Vector2, delta: float) -> Vector3:
	var applied_force: Vector3 = Vector3.ZERO

	_current_angle = calculate_steer_angle(car, input_vector.x)
	var wheel_forward: Vector3 = NodeHelpers.get_global_forward(self).rotated(NodeHelpers.get_global_up(self), _current_angle)
	var wheel_right: Vector3 = NodeHelpers.get_global_right(self).rotated(NodeHelpers.get_global_up(self), _current_angle)
	var wheel_up: Vector3 = NodeHelpers.get_global_up(self)
	var tire_velocity: Vector3 = PhysicsHelpers.get_velocity_at(car, global_position)
	var roll_velocity: float = wheel_forward.dot(tire_velocity)
	var slip_velocity: float = wheel_right.dot(tire_velocity)
	var spring_velocity: float = wheel_up.dot(tire_velocity)
	
	if _raycast.is_colliding():
		# var car_body_state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())
		# var tire_velocity: Vector3 = car_body_state.get_velocity_at_local_position(position)

		if (abs(input_vector.y) > Constants.EPSILON):
			# Calculate drive/brake force
			var percent_velocity: float = NodeHelpers.get_global_forward(car).dot(car.linear_velocity) / car.max_speed
			var accel_to_full: float = max(car.max_speed - abs(roll_velocity), 0)
			var accel: float = min(car.acceleration, accel_to_full)
			var drive_mag: float = input_vector.y * drive_percent * accel * car.mass * (car.accel_curve.sample(percent_velocity) if car.accel_curve else 1.0)
			var drive_force: Vector3 = wheel_forward * drive_mag
			if debug:
				DebugDraw.draw_ray_3d(global_position, wheel_forward, (drive_mag / (car.acceleration * car.mass)) * debug_ray_scale, Color.BLUE)
			applied_force += drive_force
		else:
			# Calculate deceleration force
			# var stop_mag = -((roll_velocity / delta) / car.get_wheel_count()) * car.mass
			var stop_mag = (-sign(roll_velocity) * car.deceleration * car.mass) / car.get_wheel_count()
			var stop_force = wheel_forward * stop_mag
			applied_force += stop_force
			pass
		
		# Calculate friction force
		var total_velocity: float = abs(slip_velocity) + abs(roll_velocity)
		var percent_slip: float = abs(slip_velocity / total_velocity)
		var friction_multiplier: float = (friction_curve.sample(percent_slip) if friction_curve else 1.0)
		var friction_mag: float = -((slip_velocity / delta) / car.get_wheel_count()) * car.mass * friction_multiplier
		var friction_force: Vector3 = wheel_right * friction_mag
		if debug:
			DebugDraw.draw_ray_3d(global_position, wheel_right, (friction_mag / (car.acceleration * car.mass)) * debug_ray_scale, Color.RED)
		applied_force += friction_force
		# Calculate force required to sustain speed lost on turns
		var angle_diff: float = abs(_prev_wheel_forward.signed_angle_to(wheel_forward, wheel_up))
		var is_steering: bool = abs(_current_angle) > Constants.EPSILON
		var has_angle_changed: bool = angle_diff > Constants.EPSILON
		var is_rolling_in_same_dir: bool = (_prev_roll_velocity < 0 and roll_velocity < 0) || (_prev_roll_velocity > 0 and roll_velocity > 0)
		var is_driving_in_same_dir: bool = (input_vector.y < 0 and roll_velocity < 0) || (input_vector.y > 0 and roll_velocity > 0) || (abs(input_vector.y) < Constants.EPSILON)
		var has_lost_speed = abs(_prev_roll_velocity) > abs(roll_velocity)
		if is_steering and has_angle_changed and is_rolling_in_same_dir and has_lost_speed and is_driving_in_same_dir:
			var velocity_diff = _prev_roll_velocity - roll_velocity
			var steer_spread: float = steer_coefficient / car.get_total_steer_coefficient()
			var redirect_mag = ((velocity_diff / delta) * car.mass) * steer_spread
			var redirect_force = wheel_forward * redirect_mag
			applied_force += redirect_force

		# Calculate spring force
		var collision_point: Vector3 = _raycast.get_collision_point()
		if debug:
			DebugDraw.draw_box(collision_point, Vector3.ONE * 0.1, Color.RED)
		_current_ground_dist = to_local(collision_point).length()
		var offset: float = suspension_rest_dist - _current_ground_dist
		var spring_mag: float = (max((offset * spring_strength) - (spring_velocity * spring_damper), 0)) * car.mass
		var spring_force: Vector3 = wheel_up * spring_mag
		if debug:
			DebugDraw.draw_ray_3d(global_position, wheel_up, (spring_mag / (PhysicsHelpers.get_gravity_3d().length() * car.mass)) * debug_ray_scale, Color.GREEN)
		applied_force += spring_force

	if debug:
		DebugDraw.set_text(str(self), str("colliding with (", MathHelpers.to_decimal_places(_current_ground_dist, 2), "): ", _raycast.get_collider()))
	
	_prev_roll_velocity = roll_velocity
	_prev_wheel_forward = wheel_forward
	_prev_wheel_right = wheel_right
	return applied_force

func calculate_steer_angle(car: Car, input_steer: float) -> float:
	return max(min(car.max_steer_angle * -input_steer, car.max_steer_angle), -car.max_steer_angle) * steer_coefficient
func add_exception(rid: RID) -> void:
	_raycast.add_exception_rid(rid)