extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

# set parent as game var
onready var game = $".."

func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
		child.initialize(game)
				
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			var object_pawn = get_cell_pawn(cell_target)
			game.logit("Objective captured! (%s, %s)" % [cell_target, object_pawn.name])
			
			object_pawn.queue_free()
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			var pawn_name = get_cell_pawn(cell_target).name
			game.logit("Cell %s contains %s" % [cell_target, pawn_name])

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2
