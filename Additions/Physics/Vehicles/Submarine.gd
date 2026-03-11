@tool
extends RigidBody3D
class_name Submarine

# The deepest the submarine can submerge
@export var maxDepth: float = 20

## The maximum speed the submarine can travel in meters per second
@export var max_speed: float = 10
## The acceleration of the submarine in meters per second squared
@export var acceleration: float = 4

@export var lift_accel: float = 1
@export var lift_decel: float = 2
@export var max_lift_speed: float = 3

## The strength of the helicopter tilts with
@export var tilt_strength: float = 5
## The damping applied to the current tilt velocity
@export var tilt_damp: float = 3

## The max speed the helicopter can rotate in radians per second
@export var max_rot_speed: float = PI / 2
## How quickly the helicopter can reach max rotation speed in radians per second squared
@export var rot_acceleration: float = PI / 2

## Data regarding the vehicle (ex. occupancy)
@export var data: VehicleData = preload("res://godot_helpers/Additions/Examples/Helicopter/helicopter_data.tres")

## Show debug data
@export var debug: bool = false
## Show bounds when debugging
@export var show_bounds: bool = false

@export_category("Buoyancy")
## The world height of the water plane
@export var waterLevel: float = 0
## Density of liquid
@export var rho: float = 150
## Should the triangle data be recalculated each time the object is submerged
@export var recalculate_triangles_on_submerge: bool = false

## The override mode used for linear damping
var linear_damp_override: Buoyancy.DampOverrideMode = Buoyancy.DampOverrideMode.REPLACE:
	set(new_override):
		linear_damp_override = new_override
		notify_property_list_changed()
		if _buoyancy:
			_buoyancy.linear_damp_override = new_override
## The rate at which this object will stop moving when submerged. Represents the linear velocity lost per second.
var submerged_linear_damp: float = 1.4:
	set(new_damp):
		submerged_linear_damp = new_damp
		notify_property_list_changed()
		if _buoyancy:
			_buoyancy.linear_damp = new_damp
## The override mode used for angular damping
var angular_damp_override: Buoyancy.DampOverrideMode = Buoyancy.DampOverrideMode.REPLACE:
	set(new_override):
		angular_damp_override = new_override
		notify_property_list_changed()
		if _buoyancy:
			_buoyancy.angular_damp_override = new_override
## The rate at which this object will stop spinning when submerged. Represents the angular velocity lost per second.
var submerged_angular_damp: float = 1.4:
	set(new_damp):
		submerged_angular_damp = new_damp
		notify_property_list_changed()
		if _buoyancy:
			_buoyancy.angular_damp = new_damp

## A [float] value clamped between -1 and 1 that represents how much to lift or sink the submarine
var input_lift: float = 0:
	set(value):
		input_lift = clampf(value, -1, 1)
## A [float] value clamped between -1 and 1 that represents how much to rotate along the yaw axis
var input_rot: float = 0:
	set(value):
		input_rot = clampf(value, -1, 1)
## A [float] value clamped between -1 and 1 that represents how much to accelerate the submarine
var input_drive: float = 0:
	set(value):
		input_drive = clampf(value, -1, 1)

var _buoyancy: Buoyancy
var _current_lift_speed: float

func _get_property_list():
	var property_list: Array = []
	property_list.append(PropertyHelpers.create_category_property("Submerged Linear Damp"))
	property_list.append(PropertyHelpers.create_enum_property(&"linear_damp_override", Buoyancy.DampOverrideMode.keys()))
	if linear_damp_override != Buoyancy.DampOverrideMode.DISABLED:
		property_list.append(PropertyHelpers.create_float_property(&"submerged_linear_damp"))
	property_list.append(PropertyHelpers.create_category_property("Submerged Angular Damp"))
	property_list.append(PropertyHelpers.create_enum_property(&"angular_damp_override", Buoyancy.DampOverrideMode.keys()))
	if angular_damp_override != Buoyancy.DampOverrideMode.DISABLED:
		property_list.append(PropertyHelpers.create_float_property(&"submerged_angular_damp"))
	
	return property_list

func _ready() -> void:
	if not Engine.is_editor_hint():
		add_child(Vehicle.new(self))

		_buoyancy = Buoyancy.new()
		_buoyancy.rho = rho
		_buoyancy.recalculate_triangles_on_submerge = recalculate_triangles_on_submerge
		_buoyancy.debug = debug
		_buoyancy.show_bounds = show_bounds
		_buoyancy.linear_damp_override = linear_damp_override
		_buoyancy.linear_damp = submerged_linear_damp
		_buoyancy.angular_damp_override = angular_damp_override
		_buoyancy.angular_damp = submerged_angular_damp
		add_child(_buoyancy)
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		Vehicle._draw_data_spots(self, data)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		# water level control
		if abs(input_lift) > 0:
			_current_lift_speed = clampf(_current_lift_speed + lift_accel * delta * input_lift, -max_lift_speed, max_lift_speed)
		else:
			_current_lift_speed = sign(_current_lift_speed) * max(abs(_current_lift_speed - lift_decel * delta * sign(_current_lift_speed)), 0)
		if _current_lift_speed > 0 and _buoyancy.waterLevel >= waterLevel:
			_current_lift_speed = 0
		if _current_lift_speed < 0 and _buoyancy.waterLevel <= waterLevel - maxDepth:
			_current_lift_speed = 0
		_buoyancy.waterLevel = clampf(_buoyancy.waterLevel + _current_lift_speed * delta, waterLevel - maxDepth, waterLevel)

		# tilt & yaw torque
		var direct_state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(self)
		var rot_inertia: Vector3 = direct_state.inverse_inertia.inverse()
		var global_forward: Vector3 = NodeHelpers.get_global_forward(self)
		var global_up: Vector3 = NodeHelpers.get_global_up(self)

		var flattened_forward: Vector3 = Vector3(global_forward.x, 0, global_forward.z).normalized()
		var target_basis: Basis = Basis.looking_at(flattened_forward, Vector3.UP, true)
		var tilt_diff_basis: Basis = target_basis * global_basis.inverse()
		var tilt_quat: Quaternion = tilt_diff_basis.get_rotation_quaternion()
		var flip_axis: bool = tilt_quat.w < 0 # for a consistent axis
		var tilt_axis: Vector3 = tilt_quat.get_axis() * (-1 if flip_axis else 1)
		var tilt_angle_offset = tilt_quat.get_angle() * (-1 if flip_axis else 1)
		if abs(tilt_angle_offset) > Constants.EPSILON:
			if debug:
				DebugDraw.draw_ray_3d(global_position, tilt_axis, 2, Color.RED)
			var angular_velocity_in_tilt: float = angular_velocity.dot(tilt_axis)
			var tilt_accel: float = (tilt_angle_offset * tilt_strength) - (angular_velocity_in_tilt * tilt_damp)
			var tilt_torque: Vector3 = rot_inertia.length() * (tilt_axis * tilt_accel)
			# remove yaw axis torque
			tilt_torque -= global_up * tilt_torque.dot(global_up)
			apply_torque(tilt_torque)

		var physics_server_inertia: Vector3 = direct_state.inverse_inertia.inverse()
		var current_angular_velocity: float = angular_velocity.dot(global_up)
		var pre_damp_angular_accel: float = input_rot * -rot_acceleration
		var total_angular_damp: float = direct_state.total_angular_damp
		var angular_cancel_damp: float = abs(total_angular_damp * (current_angular_velocity + pre_damp_angular_accel * delta))
		var input_angular_accel: float = (input_rot * -(rot_acceleration + angular_cancel_damp))
		var projected_angular_velocity: float = current_angular_velocity + input_angular_accel * delta
		if abs(projected_angular_velocity) > max_rot_speed:
			input_angular_accel = sign(input_angular_accel) * ((max_rot_speed - abs(current_angular_velocity)) + angular_cancel_damp)
		var torque: Vector3 = global_basis * (physics_server_inertia.y * (global_basis.inverse() * (global_up * input_angular_accel)))
		apply_torque(torque)
		
		# drive force
		var forward_velocity: float = global_forward.dot(linear_velocity)
		var pre_damp_accel: float = input_drive * acceleration
		var total_linear_damp: float = direct_state.total_linear_damp
		var cancel_damp_accel: float = abs(total_linear_damp * (forward_velocity + pre_damp_accel * delta))
		var input_accel: float = input_drive * (acceleration + cancel_damp_accel)
		var projected_velocity: float = forward_velocity + input_accel * delta
		if abs(projected_velocity) > max_speed:
			input_accel = sign(input_accel) * ((max_speed - abs(forward_velocity)) + cancel_damp_accel)
		var forward_force: Vector3 = global_forward * mass * input_accel
		apply_force(forward_force)

		if debug:
			DebugDraw.set_text(str(self), str("waterLevel: ", _buoyancy.waterLevel, " velocity: ", forward_velocity))