@tool
extends RigidBody3D
class_name ForceDrivenCharacter3D

## The max speed of the character in meters per second
@export var max_speed: float = 5
## How quickly the character reaches max speed in meters per second squared
@export var acceleration: float = 5
## How quickly the character slows down to a halt in meters per second squared
@export var deceleration: float = 5
## The speed the jump starts with
@export var jump_speed: float = 5
## The character model that needs rotating based on movement direction
@export var character_model: Node3D
## How far into max speed should the walk animation turn into sprint
@export_range(0, 1) var walk_percent_cutoff: float = 0.66
## Needed in order re-orient the move direction based on the look direction of the camera.
## If not set then move direction will be calculated in the global space.
@export var camera: Node3D

## Info on occupying and being occupied
@export var occupant_info: IOccupy = preload("res://godot_helpers/Additions/Physics/Vehicles/Extras/force_driven_character_occupant_info.tres")

## Show debug data
@export var debug: bool

## A [Vector2] that is normalized and represents how much to move along each axis
var input_vector: Vector2 = Vector2.ZERO:
	set(value):
		var length: float = value.length()
		input_vector = value.normalized() * min(length, 1)
## A [bool] representing the pressed state of the button that makes the character jump
var jump_btn: bool

var _floor_raycast: ShapeCast3D
var _prev_jump_btn: bool
var _prev_direction: Vector3 = Vector3.FORWARD

func _init() -> void:
	if Engine.is_editor_hint():
		self.lock_rotation = true
func _ready() -> void:
	if not Engine.is_editor_hint():
		add_child(Vehicle.new(self))
		var bounds: AABB = BoundsHelpers.get_total_bounds_3d(self, true)
		var mid_height: float = bounds.size.y / 2
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = Vector3(bounds.size.x * 0.8, mid_height + 0.2, bounds.size.z * 0.8)
		_floor_raycast = ShapeCast3D.new()
		_floor_raycast.shape = box_shape
		_floor_raycast.position = Vector3.UP * mid_height
		_floor_raycast.target_position = Vector3.DOWN * (mid_height / 2)
		_floor_raycast.exclude_parent = true
		_floor_raycast.enabled = false
		_floor_raycast.max_results = 1
		add_child(_floor_raycast)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		Vehicle._draw_exit_spots(self, occupant_info)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		# var input_vector: Vector2 = Input.get_vector("move_hor_neg", "move_hor_pos", "move_ver_neg", "move_ver_pos")
		var input_vector_dir: Vector3 = Vector3(-input_vector.x, 0, input_vector.y).normalized()
		var move_direction: Vector3 = global_basis * input_vector_dir
		var global_up: Vector3 = NodeHelpers.get_global_up(self)
		if camera:
			var camera_forward: Vector3 = NodeHelpers.get_global_forward(camera)
			camera_forward = Vector3(camera_forward.x, 0, camera_forward.z).normalized()
			var angle_to_camera: float = camera_forward.signed_angle_to(NodeHelpers.get_global_forward(self), global_up)
			move_direction = input_vector_dir.rotated(global_up, -angle_to_camera + PI)
		
		_floor_raycast.force_shapecast_update()
		var is_grounded: bool = _floor_raycast.is_colliding()
		if debug:
			DebugDraw.draw_box(to_global(_floor_raycast.position + _floor_raycast.target_position), _floor_raycast.shape.size, Color.GREEN if is_grounded else Color.RED)
		var vertical_velocity: float = linear_velocity.dot(global_up)
		if is_grounded:
			# if jump button just released
			if not jump_btn and _prev_jump_btn:
				apply_force(global_up * (jump_speed / delta) * mass)
			# undo any downwards velocity
			if vertical_velocity < 0:
				apply_force(-global_up * (vertical_velocity / delta) * mass)
			apply_force(-get_gravity() * mass)

		var move_percent: float = input_vector.length()
		if debug:
			DebugDraw.set_text(str(self), str("move_percent: ", move_percent, " velocity: ", (linear_velocity.dot(move_direction) if move_percent > Constants.EPSILON else linear_velocity.length())))
		if move_percent > Constants.EPSILON:
			var current_velocity: float = linear_velocity.dot(move_direction)
			var extraneous_velocity: Vector3 = linear_velocity - ((move_direction * current_velocity) + (global_up * vertical_velocity))
			var stop_force: Vector3 = _force_to_decel_velocity(extraneous_velocity, deceleration, mass, delta)
			if debug:
				DebugDraw.draw_ray_3d(global_position + global_up, stop_force.normalized(), (stop_force.length() / (deceleration * mass)) * 2, Color.RED)
			apply_force(stop_force)

			var accel_to_max: float = max(((move_percent * max_speed) - current_velocity) / delta, 0)
			var accel: float = min(abs(accel_to_max), acceleration)
			var move_mag: float = accel * mass
			var move_force: Vector3 = move_direction * move_mag
			if debug:
				DebugDraw.draw_ray_3d(global_position + global_up, move_direction, (move_mag / (acceleration * mass)) * 2, Color.BLUE)
			apply_force(move_force)
		else:
			var stop_force: Vector3 = _force_to_decel_velocity(linear_velocity - (global_up * vertical_velocity), deceleration, mass, delta)
			if debug:
				DebugDraw.draw_ray_3d(global_position + global_up, stop_force.normalized(), (stop_force.length() / (deceleration * mass)) * 2, Color.RED)
			apply_force(stop_force)
		
		if character_model:
			# set direction
			var current_direction: Vector3 = _prev_direction
			var air_velocity: float = linear_velocity.dot(global_up)
			var move_velocity: Vector3 = linear_velocity - (global_up * air_velocity)
			var move_speed: float = move_velocity.length()
			if move_speed > 0.1:
				current_direction = -move_velocity.normalized()
			character_model.global_basis = Basis.looking_at(current_direction, global_up)
			_prev_direction = current_direction
			# set animation
			var anim_player: AnimationPlayer = NodeHelpers.get_child_of_type(character_model, AnimationPlayer)
			if anim_player:
				if abs(air_velocity) > 0.1:
					if air_velocity > 0:
						anim_player.play("jump")
					else:
						anim_player.play("fall")
				elif move_speed > Constants.EPSILON:
					var remainder_percent: float = (1 - walk_percent_cutoff)
					var walk_percent: float = min(move_speed / (max_speed * walk_percent_cutoff), 1)
					var sprint_percent: float = max((move_speed - (max_speed * walk_percent_cutoff)) / (max_speed * remainder_percent), 0)
					if sprint_percent > 0:
						anim_player.play("sprint", -1, sprint_percent * remainder_percent + walk_percent_cutoff)
					else:
						anim_player.play("walk", -1, walk_percent)
				else:
					anim_player.play("idle")
	
	_prev_jump_btn = jump_btn

static func _force_to_decel_velocity(velocity: Vector3, decel_rate: float, body_mass: float, delta: float) -> Vector3:
	var decel_to_halt: float = velocity.length() / delta
	var decel: float = min(decel_to_halt, decel_rate)
	var stop_mag: float = decel * body_mass
	return -velocity.normalized() * stop_mag
