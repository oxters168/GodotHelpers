## An adjacency graph uses an adjacency matrix to represent its underlying connections
## The matrix cell count will always be equal to num_vertices^2
## Source: https://dev.to/russianguycoding/how-to-represent-a-graph-in-c-4cmo
extends GraphBase
class_name AdjacencyGraph

var _matrix = []
const INT64_MAX: int = 9223372036854775807

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

## Returns a bi-directional adjacency graph with the given size where every vertex is guaranteed to be reachable from any other vertex
## and the most number of connections per vertex is limited based on the given value
static func create_rand(vert_count: int, conn_max: int = INT64_MAX):
	var graph = AdjacencyGraph.new(vert_count)
	var verts_traversed: Array[int] = [0]
	while verts_traversed.size() < vert_count:
		var start_candidates: Array[int] = []
		for vert in verts_traversed:
			if graph.get_adjacent_verts(vert).size() < conn_max:
				start_candidates.append(vert)
		var start_vert = start_candidates[randi_range(0, start_candidates.size() - 1)]
		var end_candidates: Array[int] = []
		for vert in vert_count:
			var adj_verts = graph.get_adjacent_verts(vert)
			# if end point is not the same as the start point
			# if end point has not reached max connections
			# if end point is not already connected to start point
			# if end point has already been traversed then make sure this is not our last connection so we do not close the loop
			if vert != start_vert && adj_verts.size() < conn_max && !adj_verts.has(start_vert) && (!verts_traversed.has(vert) || (conn_max - graph.get_adjacent_verts(start_vert).size()) > 1):
				end_candidates.append(vert)
		var end_vert = end_candidates[randi_range(0, end_candidates.size() - 1)]
		graph.add_edge(start_vert, end_vert)
		if !verts_traversed.has(end_vert):
			verts_traversed.append(end_vert)
	return graph

## Returns an array of verts (including from and to) that represents the shortest path between the given verts.
## Source: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Pseudocode
func get_shortest_path(from: int, to: int):
	var min_dists: Array[int] = []
	var prev_verts: Array[int] = []
	var unvisited_verts: Array[int] = []
	min_dists.resize(_num_vertices)
	prev_verts.resize(_num_vertices)
	for vert in _num_vertices:
		min_dists[vert] = INT64_MAX
		prev_verts[vert] = -1
		unvisited_verts.append(vert)
	min_dists[from] = 0

	while !unvisited_verts.is_empty():
		var unvisited_vert = -1
		var min_dist = INT64_MAX
		for q in unvisited_verts:
			if min_dists[q] < min_dist:
				min_dist = min_dists[q]
				unvisited_vert = q
		unvisited_verts.erase(unvisited_vert)

		for vert in get_adjacent_verts(unvisited_vert):
			if unvisited_verts.has(vert):
				var alt = min_dists[unvisited_vert] + get_edge_weight(unvisited_vert, vert)
				if alt < min_dists[vert]:
					min_dists[vert] = alt
					prev_verts[vert] = unvisited_vert
		if unvisited_vert == to:
			break
	
	var current_vert: int = to
	var shortest_path: Array[int] = [current_vert]
	while current_vert >= 0 && current_vert != from:
		shortest_path.push_front(prev_verts[current_vert])
		current_vert = prev_verts[current_vert]
	return shortest_path
