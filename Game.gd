extends Node2D

# turn queue is used to determine the current player
onready var turn_queue : TurnQueue = $TurnQueue
onready var grid : TileMap = $Grid
onready var astar : TileMap = $Astar

onready var level = $Level
onready var target = $Target
onready var actor = $Actor

var last_mouse_position = Vector2(0,0)

var demo = false

signal logit

# Called when the node enters the scene tree for the first time.
func _ready():
	if !demo:
		new_stage()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				
func new_stage():
	level.end_level()
	var stage = level.new_level(10)
	# add two characters
	actor = level.add_actor(level.random_node())
	# something to do
	level.add_collectable(level.random_node())
	
	start_level()	
		
func start_level():
	# Add all characters to the turn_queue	
	turn_queue.initialize(level.actors)
	# first turn
	play_turn()	
	yield(level, "end_of_level")
	logit("level ended")
	
	# keep going
	new_stage()	
	
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
