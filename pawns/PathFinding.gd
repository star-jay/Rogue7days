extends Node

var random = RandomNumberGenerator.new()

var LEFT = Vector2(-1, 0)
var RIGHT = Vector2(1, 0)
var UP = Vector2(0, -1)
var DOWN = Vector2(0, 1)

var positions = [LEFT, RIGHT, UP, DOWN]
var UPLEFT = UP + LEFT
var UPRIGHT = UP + RIGHT
var DOWNLEFT = DOWN + LEFT
var DOWNRIGHT = DOWN + RIGHT
var all_positions = positions + [UPLEFT, UPRIGHT, DOWNLEFT, DOWNRIGHT]

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	pass # Replace with func body.

func random_node(size):
	return Vector2(
		random.randi_range(1, size-1),
		random.randi_range(1, size-1))

func generate_cells(size):
	var cells = []
	for x in range(size):
		for y in range(size):
			cells.append(Vector2(x, y))
	return cells

func get_neighbours(co_ords, cells):
	var neighbours = []
	for pos in positions:
		var neighbour = co_ords - pos
		if cells.find(neighbour) != -1:
			neighbours.append(neighbour)

	return neighbours

func reconstruct_path(cameFrom, current):
	var total_path = [current]
	while current in cameFrom.keys():
		current = cameFrom[current]
		total_path.insert(0, current)
	return total_path

func h(from, to):
	return from.distance_to(to)

#  A* finds a path from start to goal.
#  h is the heuristic func. h(n) estimates the cost to reach goal from node n.
func A_Star(start, goal, walkable_cells):
	# The set of discovered nodes that may need to be (re-)expanded.
	# Initially, only the start node is known.
	var openSet = []
	openSet.append(start)

	# For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from start to n currently known.
	var cameFrom = Dictionary()

	# For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
	var gScore = Dictionary()
	for cell in walkable_cells:
		gScore[cell] = INF
	# map with default value of Infinity
	gScore[start] = 0

	# For node n, fScore[n] = gScore[n] + h(n).
	var fScore = Dictionary()
	# map with default value of Infinity
	for cell in walkable_cells:
		fScore[cell] = INF
	fScore[start] = h(start, goal)

	var current

	while !openSet.empty():
		# find lowest node
		current = openSet[0]
		for node in openSet:
			if fScore[node] < fScore[current]:
				current = node

		if current == goal:
			return reconstruct_path(cameFrom, current)

		openSet.remove(openSet.find(current))
		for neighbor in get_neighbours(current, walkable_cells):
			# d(current,neighbor) is the weight of the edge from current to neighbor
			# tentative_gScore is the distance from start to the neighbor through current
			var tentative_gScore = gScore[current] + 1 # d(current, neighbor)
			if tentative_gScore < gScore[neighbor]:
				# This path to neighbor is better than any previous one. Record it!
				cameFrom[neighbor] = current
				gScore[neighbor] = tentative_gScore
				fScore[neighbor] = gScore[neighbor] + h(start, neighbor)
				if openSet.find(neighbor) == -1:
					openSet.append(neighbor)

	# Open set is empty but goal was never reached
	return null