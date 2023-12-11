class_name PhysicsHelpers

## Returns a value of seconds per physics tick
static func get_fixed_delta_time():
	return 1.0 / Engine.physics_ticks_per_second