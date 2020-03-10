extends "pawn.gd"

onready var grid = get_parent()
onready var camera = $CameraPivot/CameraOffset/Camera2D

var look_direction = Vector2(1, 0)
var grid_position = Vector2(0, 0)


func _ready():
	# set initial stats
	speed = 2
	pass
	
func start_level():	
	update_look_direction(look_direction)	
	set_camera_limits()

			
func _process(delta):
	if active:
		return
		
		# code for getting direction though pathfinding
		var input_direction = get_input_direction()
		if not input_direction:
			return
		if input_direction != look_direction:
			update_look_direction(input_direction)

		var target_position = grid.request_move(self, input_direction)
		if target_position:
			move_to(target_position)
		else:
			bump()

func get_input_direction():
	var co_ords = grid.world_to_map(self.position)
	var target = grid.get_target()
	var path = grid.find_path(self, target)
	
	if path and len(path) > 1:
		var dir = path[1] - co_ords
		return dir
		
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func update_look_direction(direction):
	self.look_direction = direction
	# $Pivot/Sprite.rotation = direction.angle()

func move_to(target_position):
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", - move_direction * 16, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position
	$Tween.start()

	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	
	self.moves_left -= 1 
	if self.moves_left <= 0:
		emit_signal("end_of_turn")
	
	set_process(true)
	
func bump():
	set_process(false)
	print('byunp')
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	self.moves_left -= 1 
	if self.moves_left <= 0:
		emit_signal("end_of_turn")
	set_process(true)


func set_camera_limits():
	if grid is TileMap:
	    var map_limits = grid.get_used_rect()
	    var map_cellsize = grid.cell_size
	    camera.limit_left = map_limits.position.x * map_cellsize.x
	    camera.limit_right = map_limits.end.x * map_cellsize.x
	    camera.limit_top = map_limits.position.y * map_cellsize.y
	    camera.limit_bottom = map_limits.end.y * map_cellsize.y
