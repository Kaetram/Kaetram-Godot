extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play('spin')

func _process(delta):
	var mouse_position = get_global_mouse_position()
	
	mouse_position.x -= 8
	mouse_position.y -= 8
	
	position = mouse_position.snapped(Vector2(16, 16))
