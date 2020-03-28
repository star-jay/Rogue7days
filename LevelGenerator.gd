extends Node

enum { EMPTY = -1, FLOOR = 0, OBSTACLE = 2, OBJECT = 1, ACTOR = 3}

var nr_of_collectables = 12
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

var distribution = {
	EMPTY: 80,
	OBJECT: 10,
	OBSTACLE: 20,
	ACTOR: 10,	
}

var level = []

func _ready():
	random.randomize()
	pass
	
func generate_level(level_size):
	level = []
	# instansiate 2 dimensional array old fashioned style
	for x in range(level_size):
		level.append([])
	
	var nr_of_players_to_place = 1
	var nr_of_collectables_to_place = nr_of_collectables
	var cell : Vector2
	# loop through all cells
	for x in range(level_size):
		for y in range(level_size):
			cell = Vector2(x, y)
			# Add walls
			if x == 0 or x == level_size-1 or y == 0 or y == level_size-1:
				level[x].append(OBSTACLE)
			else:
				level[x].append(pick_cell(x, y))
	
	return level
	
func pick_cell(x, y):
	var total = 0
	for value in distribution.values():
		 total += value
		
	var rnd = random.randf() * total
	
	for key in distribution.keys():
		rnd -= distribution[key]
		if rnd < 0:
			return key