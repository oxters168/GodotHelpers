## This is the base class of AdjacencyGraph and other possible future graph classes
## Source: https://dev.to/russianguycoding/how-to-represent-a-graph-in-c-4cmo
class_name GraphBase

var _num_vertices: int
var _directed: bool

## Creates a new directed or undirected graph object, based on the given parameter, that has the given number of vertices.
## A directed graph would be one that can have directional edges and an undirected graph would be one that has bi-directional edges.
func _init(num_vertices: int, directed: bool = false):
	_num_vertices = num_vertices
	_directed = directed

## Adds an edge connecting two vertices with the edge having the given weight.
## If the graph is defined as directed, then vert1 will connect to vert2 but not vice versa.
func add_edge(vert1: int, vert2: int, weight: int = 1):
	pass
## Returns an array of vertices connected to the given vertex.
func get_adjacent_verts(vert_index: int) -> Array[int]:
	return []
## Returns the weight value of the edge made up of the given vertices. If the graph is defined as directed, then the order of vertices
## given matters.
func get_edge_weight(vert1: int, vert2: int) -> int:
	return 0
## Returns the total number of vertices the graph contains.
func get_vert_count():
	return _num_vertices