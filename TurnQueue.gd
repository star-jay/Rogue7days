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
	for player in players:
		if player.type == CELL_TYPES.ACTOR:
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
		print("wait")
		active_character.play_turn()
		yield(active_character, "moved")
		print("moved")
		
		# Cycle through characters
		print(len(characters))
		
		var new_index = int (active_character.get_index() + 1) % len(characters)
		set_active_character(new_index)
		
		print("end of turn")
		emit_signal("end_of_turn")