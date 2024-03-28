@tool
extends Node3D
class_name DraggableSphere

## Latitude = X-Axis, Normal = Y-Axis, Longitude = Z-Axis
enum Axis { LATITUDE, NORMAL, LONGITUDE }

@export var diameter: float = 0.12:
	set(value):
		diameter = value
		_reset_sphere()
		_reset_drag_cubes()

var _start_mouse_pos: Vector2
var _initial_sphere_pos: Vector3
var _distance_from_cam: float
var _current_drag_axis: Axis
var _is_dragging_axis: bool
var _mesh_instance: MeshInstance3D
var _drag_planes: Array[Area3D]
var _drag_plane_mats: Array[Material]
var _mouse_pressed: bool

func _init():
	_reset_sphere()
	_reset_drag_cubes()

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !_mouse_pressed:
			_mouse_pressed = true
			var result = PhysicsHelpers.raycast_from_mouse_3d(100, ~0, true)
			if result.has("collider") && result.collider is Area3D:
				var plane_index: int = _drag_planes.find(result.collider)
				if plane_index >= 0:
					_distance_from_cam = CameraHelpers.get_active_camera_3d().global_position.distance_to(result.position)
					_current_drag_axis = plane_index as Axis
					_start_mouse_pos = get_viewport().get_mouse_position()
					_initial_sphere_pos = global_position
					_is_dragging_axis = true
	else:
		_mouse_pressed = false
		_is_dragging_axis = false
	
	if _is_dragging_axis:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var camera: Camera3D = CameraHelpers.get_active_camera_3d()
		var mouse_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var mouse_normal: Vector3 = camera.project_ray_normal(mouse_pos)
		var offset_pos: Vector3 = mouse_origin + mouse_normal * _distance_from_cam
		var plane_normal: Vector3 = NodeHelpers.get_global_right(self)
		if _current_drag_axis == Axis.NORMAL:
			plane_normal = NodeHelpers.get_global_up(self)
		elif _current_drag_axis == Axis.LONGITUDE:
			plane_normal = NodeHelpers.get_global_forward(self)
		var pos_diff: Vector3 = VectorHelpers.project_on_plane(VectorHelpers.project_on_plane(offset_pos, plane_normal) - _initial_sphere_pos, plane_normal)
		global_position = _initial_sphere_pos + pos_diff
	
	_face_camera()

func _face_camera():
	var cam: Camera3D = CameraHelpers.get_active_camera_3d()
	if cam != null:
		var cam_forward: Vector3 = NodeHelpers.get_global_forward(cam)
		for i in _drag_planes.size():
			var plane_dir: Vector3 = Vector3.RIGHT
			if i == Axis.LATITUDE:
				if cam_forward.dot(NodeHelpers.get_global_right(self)) < 0:
					## looking left
					plane_dir = Vector3.RIGHT
				else:
					## looking right
					plane_dir = Vector3.LEFT
			elif i == Axis.NORMAL:
				if cam_forward.dot(NodeHelpers.get_global_up(self)) < 0:
					## looking up
					plane_dir = Vector3.DOWN
				else:
					## looking down
					plane_dir = Vector3.UP
			elif i == Axis.LONGITUDE:
				if cam_forward.dot(NodeHelpers.get_global_forward(self)) < 0:
					## looking back
					plane_dir = Vector3.FORWARD
				else:
					## looking forward
					plane_dir = Vector3.BACK
			_drag_planes[i].position = plane_dir * (_get_sphere_radius() + _get_plane_thickness())

func _get_plane_size() -> float:
	return diameter * 0.66
func _get_plane_thickness() -> float:
	return diameter / 10
func _get_sphere_radius() -> float:
	return diameter / 2

func _reset_sphere():
	if _mesh_instance != null:
		remove_child(_mesh_instance)
		_mesh_instance = null
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mesh_instance = MeshHelpers.create_sphere_3d(diameter / 2, diameter, mat)
	add_child(_mesh_instance)
func _reset_drag_cubes():
	if _drag_planes != null:
		for i in _drag_planes.size():
			remove_child(_drag_planes[i])
		_drag_planes.clear()
		
	_drag_planes = []
	_drag_planes.resize(Axis.size())
	_drag_plane_mats = []
	_drag_plane_mats.resize(Axis.size())
	for i in _drag_planes.size():
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_drag_plane_mats[i] = mat

		var radius: float = _get_sphere_radius()
		var plane_size: float = _get_plane_size()
		var plane_thickness: float = _get_plane_thickness()
		var pos: Vector3 = Vector3.ZERO
		var size: Vector3 = Vector3.ONE * plane_size
		if i == Axis.LATITUDE:
			pos = Vector3(radius + plane_thickness, 0, 0)
			size = Vector3(plane_thickness, plane_size, plane_size)
			mat.albedo_color = Color.RED
		elif i == Axis.NORMAL:
			pos = Vector3(0, radius + plane_thickness, 0)
			size = Vector3(plane_size, plane_thickness, plane_size)
			mat.albedo_color = Color.GREEN
		elif i == Axis.LONGITUDE:
			pos = Vector3(0, 0, radius + plane_thickness)
			size = Vector3(plane_size, plane_size, plane_thickness)
			mat.albedo_color = Color.BLUE
		var drag_plane: Area3D = PhysicsHelpers.create_area_box_3d(size, Vector3.ZERO, Quaternion.IDENTITY, true, mat)
		add_child(drag_plane)
		drag_plane.position = pos
		_drag_planes[i] = drag_plane