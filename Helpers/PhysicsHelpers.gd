class_name PhysicsHelpers

## Returns a value of seconds per physics tick
static func get_fixed_delta_time():
	return 1.0 / Engine.physics_ticks_per_second

## Calculates the force vector required to be applied to a rigidbody through AddForce to achieve the desired speed. Works with the Force ForceMode.
## @param mass: The mass of the rigidbody.</param>
## @param velocity: The velocity of the rigidbody.</param>
## @param desiredVelocity: The velocity that you'd like the rigidbody to have.</param>
## @param timestep: The delta time between frames.</param>
## @param accountForGravity: Oppose gravity force?</param>
## @param maxForce: The max force the result can have.</param>
## <returns>The force value to be applied to the rigidbody.</returns>
static func calculate_required_force_for_speed_2d(mass: float, velocity: Vector2, desiredVelocity: Vector2, timestep: float = 0.02, accountForGravity: bool = false, maxForce: float = Constants.FLOAT_MAX) -> Vector2:
	var nakedForce: Vector2 = desiredVelocity / timestep
	nakedForce *= mass

	var currentForce: Vector2 = (velocity / timestep) * mass

	var gravityForce: Vector2 = Vector2.ZERO
	if accountForGravity:
		var gravity_vector: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
		var gravity_magnitude: int = ProjectSettings.get_setting("physics/2d/default_gravity")
		gravityForce = gravity_vector * gravity_magnitude * mass

	var deltaForce: Vector2 = nakedForce - (currentForce + gravityForce)

	return VectorHelpers.max_mag2(deltaForce, maxForce)

## Calculates the force value required to be applied to a rigidbody through AddForce to achieve the desired speed. Works with the Force ForceMode.
## @param mass: The mass of the rigidbody.</param>
## @param velocity: The velocity of the rigidbody.</param>
## @param desiredVelocity: The velocity that you'd like the rigidbody to have.</param>
## @param timestep: The delta time between frames.</param>
## @param accountForGravity: Oppose gravity force?</param>
## @param maxForce: The max force the result can have.</param>
## <returns>The force value to be applied to the rigidbody.</returns>
static func calculate_required_force_for_speed_1d(mass: float, velocity: float, desiredVelocity: float, timestep: float = 0.02, accountForGravity: bool = false, maxForce: float = Constants.FLOAT_MAX) -> float:
	var nakedForce: float = desiredVelocity / timestep
	nakedForce *= mass

	var currentForce: float = (velocity / timestep) * mass

	var gravityForce: int = 0
	if (accountForGravity):
			gravityForce = -ProjectSettings.get_setting("physics/2d/default_gravity") * mass;

	var deltaForce: float = nakedForce - (currentForce + gravityForce)

	if (deltaForce > maxForce):
			deltaForce = maxForce

	return deltaForce