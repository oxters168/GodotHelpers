class_name PhysicsHelpers

## Returns a value of seconds per physics tick
static func get_fixed_delta_time():
	return 1.0 / Engine.physics_ticks_per_second

## Gets the current angular velocity on the given axis in rad/s
static func get_axis_angular_velocity(rigidbody: RigidBody3D, axis: Vector3 = Vector3.UP, normal: Vector3 = Vector3.FORWARD) -> float:
	var rot_dir: float = sign(rigidbody.angular_velocity.dot(axis))
	var current_ang_vel: float = rot_dir * VectorHelpers.project_on_plane(rigidbody.angular_velocity, normal).length()
	return current_ang_vel

## Creates a raycast with the given values and returns the dictionary result of [method PhysicsDirectSpaceState3D.intersect_ray]
static func raycast_3d(
	origin: Vector3,
	direction: Vector3,
	distance: float,
	collision_mask: int = ~0,
	collide_with_areas: bool = false,
	collide_with_bodies: bool = true,
	exclude: Array[RID] = [],
	hit_back_faces: bool = true,
	hit_from_inside: bool = false
) -> Dictionary:
	var space_state = Engine.get_main_loop().current_scene.get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.collide_with_areas = collide_with_areas
	params.collide_with_bodies = collide_with_bodies
	params.exclude = exclude
	params.hit_back_faces = hit_back_faces
	params. hit_from_inside = hit_from_inside
	params.collision_mask = collision_mask
	params.from = origin
	params.to = origin + direction * distance
	return space_state.intersect_ray(params)

## Rotates the given rigidbody to the specified angle (should be in radians) along an axis
static func rotate_to(rigidbody: RigidBody3D, axis: Vector3, normal: Vector3, angle: float, acceleration: float, max_speed: float, deceleration: float, delta_time: float):
	var current_ang_vel: float = PhysicsHelpers.get_axis_angular_velocity(rigidbody, axis, normal)
	var rot_dir = sign(current_ang_vel)
	var back: Vector3 = NodeHelpers.get_global_back(rigidbody)
	var current_angle: float = VectorHelpers.get_clockwise_angle_3d(normal, back, axis)
	# DebugDraw.set_text("rotate_to", str("requested_angle(", angle, ") current_angle(", current_angle, ") ang_vel(", current_ang_vel, ")"))
	# To avoid going the wrong way to reach an angle
	if (abs(angle - current_angle) > PI):
		current_angle += sign(angle - current_angle) * (2 * PI)
	var angle_travel_left: float = abs(angle - current_angle)
	var dir_to_go: float = sign(angle - current_angle)

	# How much time would it take us to decelerate based on our current velocity
	var deceleration_time: float = abs(current_ang_vel / deceleration)
	# How much time would it take us to reach our desired angle based on our current velocity
	var reach_time: float = abs(angle_travel_left / current_ang_vel)
	
	# If the amount of time to decelerate is longer than the amount of time it would take our momentum to reach (if we're overshooting), then start decelerating
	if (deceleration_time >= reach_time):
		var expected_dec = (abs(current_ang_vel) / delta_time)
		var rot_acc_value = -rot_dir * min(deceleration, expected_dec)
		rigidbody.apply_torque(rot_acc_value * axis * rigidbody.mass)
	else:
		var expected_acc = angle_travel_left / (delta_time * delta_time)
		# If we're currently rotating in the opposite direction of what we want, use the deceleration value instead of acceleration
		var rot_acc_value = (dir_to_go * (deceleration if sign(dir_to_go) != rot_dir else min(acceleration, expected_acc)))
		if (abs(current_ang_vel + (rot_acc_value * delta_time)) >= max_speed):
			rot_acc_value = dir_to_go * (max_speed - abs(current_ang_vel))
		
		rigidbody.apply_torque(rot_acc_value * axis * rigidbody.mass)

## Rotates the rigidbody in a direction along an axis
static func rotate(rigidbody: RigidBody3D, axis: Vector3, normal: Vector3, input: float, acceleration: float, max_speed: float, deceleration: float, delta_time: float):
	var current_ang_vel = PhysicsHelpers.get_axis_angular_velocity(rigidbody, axis, normal)
	var rot_dir = sign(current_ang_vel)
	# If we're currently rotating in the opposite direction of what we want, use the deceleration value instead of acceleration
	var rot_acc_value: float = 0
	var input_rot: bool = abs(input) > Constants.EPSILON

	# if input is being received and in the next frame we are still under out speed goal then apply the expected acceleration
	# or deceleration based on which way we are inputting
	if input_rot && max_speed > Constants.EPSILON && abs(current_ang_vel + (rot_acc_value * delta_time)) < max_speed:
		rot_acc_value = input * (deceleration if sign(input) != rot_dir else acceleration)
	# if input is being received and in the next frame we will overshoot our speed goal then only apply the needed amount of
	# acceleration
	elif input_rot && max_speed > Constants.EPSILON && abs(current_ang_vel + (rot_acc_value * delta_time)) >= max_speed:
		rot_acc_value = sign(rot_acc_value) * (max_speed - abs(current_ang_vel))
	# else if input is not being received and the next frame we will not overshoot our rest speed goal then only apply the
	# expected deceleration amount
	elif abs(current_ang_vel) >= (deceleration * delta_time):
		rot_acc_value = -rot_dir * deceleration
	# else if input is not being received and our speed is still not at rest then apply a deceleration value calculated through our
	# current speed to only apply the amount needed to reach rest
	elif abs(current_ang_vel) > Constants.EPSILON:
		rot_acc_value = -(current_ang_vel / delta_time)
	# DebugDraw.set_text("Rotate", str("input(", input, ") max_speed(", max_speed, ") applied_acc(", rot_acc_value, ")"))
	rigidbody.apply_torque(axis * rot_acc_value * rigidbody.mass)

## Retrieves the gravity direction vector from the project settings
static func get_gravity_vector_3d() -> Vector3:
	return ProjectSettings.get_setting("physics/3d/default_gravity_vector")
## Retrieves the gravity vector magnitude from the project settings
static func get_gravity_magnitude_3d() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity")
## Combines the gravity direction vector and magnitude to create the gravity force vector
static func get_gravity_3d() -> Vector3:
	return get_gravity_vector_3d() * get_gravity_magnitude_3d()
## Retrieves the gravity direction vector from the project settings
static func get_gravity_vector_2d() -> Vector2:
	return ProjectSettings.get_setting("physics/2d/default_gravity_vector")
## Retrieves the gravity vector magnitude from the project settings
static func get_gravity_magnitude_2d() -> int:
	return ProjectSettings.get_setting("physics/2d/default_gravity")
## Combines the gravity direction vector and magnitude to create the gravity force vector
static func get_gravity_2d() -> Vector2:
	return get_gravity_vector_2d() * get_gravity_magnitude_2d()

## Calculates the force vector required to be applied to a rigidbody through [method RigidBody2D.apply_central_force] to achieve the desired speed
static func calculate_required_force_for_speed_2d(
	mass: float,
	velocity: Vector2,
	desired_velocity: Vector2,
	timestep: float = 0.02,
	account_for_gravity: bool = false,
	max_force: float = Constants.FLOAT_MAX
) -> Vector2:
	var naked_force: Vector2 = desired_velocity / timestep
	naked_force *= mass

	var current_force: Vector2 = (velocity / timestep) * mass

	var gravity_force: Vector2 = Vector2.ZERO
	if account_for_gravity:
		gravity_force = get_gravity_2d() * mass

	var delta_force: Vector2 = naked_force - (current_force + gravity_force)

	return VectorHelpers.max_mag2(delta_force, max_force)

## Calculates the force value required to be applied to a rigidbody through [method RigidBody2D.apply_central_force] to achieve the desired speed
static func calculate_required_force_for_speed_1d(
	mass: float,
	velocity: float,
	desired_velocity: float,
	timestep: float = 0.02,
	account_for_gravity: bool = false,
	max_force: float = Constants.FLOAT_MAX
) -> float:
	var naked_force: float = desired_velocity / timestep
	naked_force *= mass

	var current_force: float = (velocity / timestep) * mass

	var gravity_force: int = 0
	if (account_for_gravity):
		gravity_force = get_gravity_magnitude_2d() * mass

	var delta_force: float = naked_force - (current_force + gravity_force)

	if (delta_force > max_force):
			delta_force = max_force

	return delta_force
