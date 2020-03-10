extends YSort

class_name TurnQueue
# Declare member variables here. Examples:
enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
var active_character
var characters : Array

signal end_of_turn

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize(players):
	characters = []
	for player in players:
		if player.type == CELL_TYPES.ACTOR:
			player.start_level()
			characters.append(player)
	
	set_active_character(0)
	
func set_active_character(index : int):
	if active_character:
		active_character.active = false
	var pawn = characters[index]
	if pawn:
		active_character = pawn
		pawn.active = true

func play_turn():
	if len(characters) > 0:
		# print("wait")
		active_character.camera.current = true
		active_character.play_turn()
		
		# wait until character is done with his turn
		yield(active_character, "end_of_turn")
		
		# Cycle through characters
		var new_index = int (characters.find(active_character) + 1) % len(characters)
		set_active_character(new_index)
		
		# print("end of turn")
		emit_signal("end_of_turn")