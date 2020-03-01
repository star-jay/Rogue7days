extends Position2D

onready var parent = $'..'

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	update_look_direction()

func update_look_direction():
	rotation = parent.look_direction.angle()
	