@tool
extends MeshInstance3D
class_name PixelArtPPMesh

var _quad_mesh: QuadMesh
var _quad_mat: ShaderMaterial

func _init():
	_quad_mat = ShaderMaterial.new()
	_quad_mat.shader = preload("../Shaders/OutlinePP.gdshader")
	_quad_mat.set_shader_parameter("darken_amount", 0)

	_quad_mesh = QuadMesh.new()
	_quad_mesh.size = Vector2(2, 2)
	_quad_mesh.flip_faces = true
	_quad_mesh.material = _quad_mat

	extra_cull_margin = Constants.FLOAT_MAX
	mesh = _quad_mesh