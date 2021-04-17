extends Node

var encrypt_password = OS.get_unique_id()
var config_path = 'user://kaetram_config.dat'

func _ready():
	OS.min_window_size = Vector2(800, 600)
