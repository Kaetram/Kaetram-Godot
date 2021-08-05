extends Node

var debug = false
var encrypt_password = OS.get_unique_id()

const tile_size = 16
const config_path = 'user://kaetram_config.dat'

# We update this when receiving data from server
# TODO - Save actual map size from server and load it here
var map_size = Vector2(700, 500)

func _ready():
	OS.min_window_size = Vector2(800, 600)
