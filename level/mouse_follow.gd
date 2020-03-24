extends Node2D

onready var level = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# cath mouse movement
	if event is InputEventMouseMotion:
		var mouse_position = get_global_mouse_position()
		print(event.position, mouse_position, event.global_position)
		self.position = level.map_to_world(
			level.world_to_map(mouse_position))
		# actor.position = event.position