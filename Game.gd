extends Node2D

# turn queue is used to determine the current player
onready var turn_queue : TurnQueue = $TurnQueue
onready var grid : TileMap = $Grid
onready var astar : TileMap = $Astar

onready var level_generator = $LevelGenerator
onready var target = $Target

var last_mouse_position = Vector2(0,0)
var actor

signal logit

# Called when the node enters the scene tree for the first time.
func _ready():
	new_level()
	
func _input(event):
	# cath mouse movement
	# get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			var mouse_position = get_global_mouse_position()
			target.position = grid.map_to_world(grid.world_to_map(mouse_position))
			
			
			if actor:
				var path = grid.find_path(actor, target)
				if path:
					for cell in path:
						grid.add_collectable(cell)
				
func new_level():
	var level = level_generator.generate_level(10)
	grid.load_level(level)
	# add two characters
	actor = grid.add_actor(grid.random_node())
	
	# something to do
	grid.add_collectable(grid.random_node())
	
	start_level()	
		
func start_level():
	# Add all characters to the turn_queue	
	turn_queue.initialize(grid.actors)
	# first turn
	play_turn()	
	yield(grid, "end_of_level")
	grid.end_level()
	logit("level ended")

	new_level()	
	
func play_turn():
	var pawn : Pawn = get_active_pawn()
	var targets : Array

	if pawn:
		turn_queue.play_turn()
		yield(turn_queue, "end_of_turn")
		play_turn()	
				
func get_active_pawn() -> Pawn:
	return turn_queue.active_character
	
func logit(text):
	emit_signal("logit", text)
