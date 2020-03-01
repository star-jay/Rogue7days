extends Node

# turn queue is used to determine the current player
onready var turn_queue : TurnQueue = $TurnQueue

signal logit

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_queue.initialize(find_node('Grid').get_children())
	play_turn()

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