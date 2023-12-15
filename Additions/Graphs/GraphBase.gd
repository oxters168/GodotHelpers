## This is the base class of AdjacencyGraph and other possible future graph classes
## Source: https://dev.to/russianguycoding/how-to-represent-a-graph-in-c-4cmo
class_name GraphBase

var _num_vertices: int
var _directed: bool

func _init(num_vertices: int, directed: bool = false):
	_num_vertices = num_vertices
	_directed = directed

func add_edge(vert1: int, vert2: int, weight: int = 1):
	pass
func get_adjacent_verts(vert_index: int) -> Array[int]:
	return []
func get_edge_weight(vert1: int, vert2: int) -> int:
	return 0
func get_vert_count():
	return _num_vertices