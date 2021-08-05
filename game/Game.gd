extends Node2D

var Connection = Networking._connection

onready var Map = get_node('Canvas/Map')
onready var Player = get_node('Canvas/Player')
onready var Loading = get_node('GUI/Loading')
onready var Cursor = get_node('Canvas/Map/Cursor')
onready var Debug = get_node('Debugging/DebugMenu')

const Packets = preload('res://network/Packets.gd')

# Called when the node enters the scene tree for the first time.
func _ready():
	Networking.set_handler(self, 'Game')
	Networking.reconnection_attempts = 0
	
	Loading.set_position(Vector2(OS.window_size.x / 2, OS.window_size.y / 2))
	
var debug_toggled = false

func get_mouse_grid_position(mouse_position):
	return Vector2(int(floor(mouse_position.x / 16)), int(floor(mouse_position.y / 16)))

func _unhandled_input(event):
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
		
	var start_position = Player.get_start_position()
	var end_position = get_mouse_grid_position(get_global_mouse_position())
	var path = Astar.find_path(start_position, end_position)
	
	if len(path) < 2:
		return
	
	Player.set_path(path)
		
func _unhandled_key_input(event):
	var x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	var y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	
	Player.handle_key_input(x, y)
	
	if debug_toggled:
		if event.scancode == KEY_9:
			Debug.visible = not Debug.visible
	
	if Input.is_action_just_released('ui_debug'):
		debug_toggled = true
		return
		
	debug_toggled = false

func handle_packet(data, _utf8 = false):
	if typeof(data) == TYPE_STRING:
		print('Received UTF8 Response: ' + data)
		return
	
	var packet_id = int(data.pop_front())
	var _opcode
	
	match packet_id:
		Packets.Handshake:
			print('Received handshake in-game (reconnection)...')
			Connection.send_login()
			
		Packets.Welcome:
			print('Received welcome packet!')
			
			var player_info = data.pop_front()
			var x = player_info.x * Globals.tile_size - (Globals.tile_size / 2)
			var y = player_info.y * Globals.tile_size - (Globals.tile_size / 2)
		
			Player.set_position(Vector2(x, y))
			
			Connection.send_ready()
			
		Packets.Region:
			print('Received region packet!')
			Map.handle_region(data)
			
			Loading.visible = false
			Cursor.visible = true
			
func _process(delta):
	if Connection.has_packet_queue():
		handle_packet(Connection.get_packet_from_queue())

# ------------- Debug Buttons -------------

var step = 0
func _on_debug_vector_button():
	if step % 4 == 0: # up
		Player.set_animations(Vector2(0, -1))
	elif step % 4 == 1: # right
		Player.set_animations(Vector2(1, 0))
	elif step % 4 == 2: # down
		Player.set_animations(Vector2(0, 1))
	elif step % 4 == 3: # left
		Player.set_animations(Vector2(-1, 0))
	
	step += 1

func _on_debug_move_button():
	Player.move_down()
