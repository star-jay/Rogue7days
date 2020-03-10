extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

# set parent as game var
onready var game = $".."
onready var path_finder = $PathFinder
onready var actor = $Actor

# onready var level_generator = $LevelGenerato
var random = RandomNumberGenerator.new()

var collectables = []
var actors = []
var size
var target
var last_mouse_position

signal end_of_level

func _ready():
	pass 
	
func _input(event):
	# cath mouse movement
	if event is InputEventMouseMotion:
		last_mouse_position = world_to_map(event.global_position)
		# actor.position = event.position

	
func load_level(level):
	size = len(level)
	collectables = []
	actors = []
	
	for x in range(size):
		for y in range(size):
			var position = Vector2(x, y)
			var value = level[x][y]
			if value == OBSTACLE:	
				add_obstacle(position)
			else:
				set_cellv(position, -1)

func get_collectable(co_ords):
	for node in collectables:
		if node:
			if world_to_map(node.position) == co_ords:
				return(node)
			
func new_target():
	# are there collectables left
	if len(collectables) > 0:
		var index = random.randi_range(0, len(collectables)-1)
		print("New target %s from possible %s" % [index, len(collectables)])
		target = collectables[index]
		print(target.visible)
	# level is over
	else:
		emit_signal("end_of_level")
	
func get_target():
	if not target:
		new_target()
	else:
		# check if target still live
		if collectables.find(target) == -1:
			print("Remove Old target %s: %s" % [collectables.find(target), target.name])
			new_target()
	return target 
			
func get_actor(co_ords):
	for node in actors:
		if world_to_map(node.position) == co_ords:
			return(node)
			
func remove_collectable(index):
	print("remove collectable index (%s)" % [index])
	var node = collectables[index]
	collectables.remove(index)
		
	if node == target:
		print("Target captured! (%s)" % [node.name])
		target = null
	else:
		print("Other objective... removed it!")
	
	node.visible = false
	print("free node (%s)" % [node.name])
	
			
func collect_objective(co_ords):
	var object_pawn = get_collectable(co_ords)
	var index = collectables.find(object_pawn)
	
	if object_pawn:
		remove_collectable(index)
		set_cellv(co_ords, -1)
		
	if len(collectables) == 0:
		emit_signal("end_of_level")

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			collect_objective(cell_target)			
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:			
			game.logit("Cell %s contains actor")

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2
	
func add_collectable(grid_position : Vector2):
	var scene = load("res://pawns/Collectable.tscn")
	var collectable = scene.instance()
	collectable.set_name("collectable_%s" % [collectables.size(), ])
	collectable.position = map_to_world(grid_position) + cell_size / 2
	collectable.type = OBJECT
	set_cellv(grid_position, OBJECT)
	add_child(collectable)
	collectables.append(collectable)

func add_actor(grid_position : Vector2):
	var scene = load("res://pawns/Actor.tscn")
	var actor = scene.instance()
	
	actor.set_name("Player %s " % [len(actors) + 1])
	actor.position = map_to_world(grid_position) # + cell_size / 2
	actor.type = ACTOR
	add_child(actor)
	actors.append(actor)
	return actor

func add_obstacle(grid_position : Vector2):
	set_cellv(grid_position, OBSTACLE)
	
func find_path(from_node, to_node):
	return path_finder.A_Star(
		world_to_map(from_node.position), 
		world_to_map(to_node.position),
		get_walkable_cells()
	)
	
func get_walkable_cells():
	var cells = []
	for x in range(size):
		for y in range(size):
			# TODO: fix this
			if get_cellv(Vector2(x, y)) != 1:
				cells.append(Vector2(x, y))
	return cells
	
func random_node():
	var cells = get_walkable_cells()
	return cells[random.randi_range(0, len(cells)-1)]
	
	
func end_level():
	clear()
	for node in collectables:
		node.queue_free()
	for node in actors:
		node.queue_free()