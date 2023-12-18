## An adjacency graph uses an adjacency matrix to represent its underlying connections
## The matrix cell count will always be equal to num_vertices^2
## Source: https://dev.to/russianguycoding/how-to-represent-a-graph-in-c-4cmo
extends GraphBase
class_name AdjacencyGraph

var _matrix = []

## Creates a new directed or undirected graph object, based on the given parameter, that has the given number of vertices.
## A directed graph would be one that can have directional edges and an undirected graph would be one that has bi-directional edges.
func _init(num_vertices: int, directed: bool = false):
	super(num_vertices, directed)
	_fill_empty_matrix()

func _fill_empty_matrix():
	for i in _num_vertices:
		_matrix.append([])
		for j in _num_vertices:
			_matrix[i].append(0)

## Adds an edge connecting two vertices with the edge having the given weight.
## If the graph is defined as directed, then vert1 will connect to vert2 but not vice versa.
func add_edge(vert1: int, vert2: int, weight: int = 1):
	assert(vert1 < _num_vertices && vert2 < _num_vertices && vert1 >= 0 && vert2 >= 0, "Vertices are out of bounds")
	assert(weight >= 1, "Weight cannot be less than 1")
	
	_matrix[vert1][vert2] = weight
	# In an undirected graph all edges are bi-directional
	if (!_directed):
		_matrix[vert2][vert1] = weight

## Returns an array of vertices connected to the given vertex.
func get_adjacent_verts(vert_index: int) -> Array[int]:
	assert(vert_index < _num_vertices && vert_index >= 0, "Vertex is out of bounds")
	var adjacent: Array[int] = []
	for i in _num_vertices:
		if _matrix[vert_index][i] > 0:
			adjacent.append(i)
	return adjacent

## Returns the weight value of the edge made up of the given vertices. If the graph is defined as directed, then the order of vertices
## given matters.
func get_edge_weight(vert1: int, vert2: int) -> int:
	assert(vert1 < _num_vertices && vert2 < _num_vertices && vert1 >= 0 && vert2 >= 0, "Vertices are out of bounds")
	return _matrix[vert1][vert2]
