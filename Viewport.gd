extends Viewport

onready var game : TileMap = $Game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# cath mouse movement
	if event is InputEventMouseMotion:
		game.last_mouse_position = get_mouse_position()
