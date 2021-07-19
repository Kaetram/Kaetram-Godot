extends Node

var encrypt_password = OS.get_unique_id()

const tile_size = 16
const config_path = 'user://kaetram_config.dat'

func _ready():
	OS.min_window_size = Vector2(800, 600)
