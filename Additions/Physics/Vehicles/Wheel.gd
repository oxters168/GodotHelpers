extends Node3D
## Wheel physics based on this youtube video by Toyful Games
## https://youtu.be/CdPYlj5uZeI?si=iQMB-u82wBhdgD-X
class_name Wheel

## The distance to the wheel from the suspension in meters if no force was being applied
@export var suspension_rest_dist: float = 0.8
## The strength of the spring
@export var spring_strength: float = 20
## The amount of dampening strength the spring has
@export var spring_damper: float = 0.5
## The radius of the wheel in meters
@export var wheel_radius: float = 0.5
## The thickness of the wheel in meters
@export var wheel_thickness: float = 0.1
## The maximum angle to the wheel can rotate in radians
@export var max_steer_angle: float = PI / 4
## The multiplier on the steer angle of the wheel when the angle is set (applied after clamping)
@export_range(0, 1) var steer_coefficient: float = 1
## The percent force this wheel has to drive from the acceleration of the wheelable vehicle
@export_range(0, 1) var drive_percent: float = 0.25
## How much percent slip the wheel resists, represented by the y-axis, in relation to the percent
## velocity it currently has along the slip direction, represented by the x-axis
@export var friction_curve: Curve

var _raycast: RayCast3D

func _init() -> void:
	_raycast = RayCast3D.new()
	_raycast.target_position = Vector3.DOWN * (suspension_rest_dist + wheel_radius)
	add_child(_raycast)

func calculate_force_on_vehicle(car: Car, input_vector: Vector2, delta: float) -> Vector3:
	var applied_force: Vector3 = Vector3.ZERO

	if _raycast.is_colliding():
		var car_body_state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())
		var tire_velocity: Vector3 = car_body_state.get_velocity_at_local_position(position)
		var wheel_forward: Vector3 = NodeHelpers.get_global_forward(self)
		var roll_velocity: float = wheel_forward.dot(tire_velocity)
		var wheel_right: Vector3 = NodeHelpers.get_global_right(self).rotated(NodeHelpers.get_global_up(car), calculate_steer_angle(input_vector.x))
		var slip_velocity: float = wheel_right.dot(tire_velocity)
		var wheel_up: Vector3 = NodeHelpers.get_global_up(self)
		var spring_velocity: float = wheel_up.dot(tire_velocity)

		if (abs(input_vector.y) > Constants.EPSILON):
			# Calculate drive/brake force
			var percent_velocity: float = NodeHelpers.get_global_forward(car).dot(car.linear_velocity) / car.max_speed
			var accel_to_full: float = max(car.max_speed - abs(roll_velocity), 0) / delta
			var accel: float = min(car.acceleration, accel_to_full)
			var drive_mag: float = input_vector.y * accel * car.mass * car.accel_curve.sample(percent_velocity) if car.accel_curve else 1.
			var drive_force: Vector3 = wheel_forward * drive_mag
			DebugDraw.draw_ray_3d(global_position, wheel_forward, (drive_mag / (car.acceleration * car.mass)) * 5, Color.BLUE)
			applied_force += drive_force
		else:
			# Calculate stop force
			# // const stopMag = -((rollVelocity / deltaTime) / this.vehicle.getWheelCount()) * vehicleMass
			# // const stopForce = wheelForward.multiplyByFloats(stopMag, stopMag, stopMag)
			# // appliedForce.addInPlace(stopForce)
			pass
		
		# Calculate friction force
		var total_velocity: float = abs(slip_velocity) + abs(roll_velocity)
		var percent_slip: float = abs(slip_velocity / total_velocity)
		var friction_multiplier: float = friction_curve.sample(percent_slip) if friction_curve else 1.
		var friction_mag: float = ((slip_velocity / delta) / car.get_wheel_count()) * car.mass * friction_multiplier
		var friction_force: Vector3 = wheel_right * friction_mag
		DebugDraw.draw_ray_3d(global_position, wheel_right, friction_mag, Color.RED)
		applied_force += friction_force

		# Calculate spring force
		var ground_dist: float = suspension_rest_dist - to_local(_raycast.get_collision_point()).length()
		var spring_mag: float = max((ground_dist * spring_strength) - (spring_velocity * spring_damper), 0)
		var spring_force: Vector3 = wheel_up * spring_mag
		DebugDraw.draw_ray_3d(global_position, wheel_up, (spring_mag / (PhysicsHelpers.get_gravity_3d().length() * car.mass)) * 5, Color.GREEN)
		applied_force += spring_force
	
	return applied_force

func calculate_steer_angle(input_steer: float) -> float:
	return max(min(max_steer_angle * input_steer, max_steer_angle), -max_steer_angle) * steer_coefficient
func add_exception(rid: RID) -> void:
	_raycast.add_exception_rid(rid)