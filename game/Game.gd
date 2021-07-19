extends Node2D

var Connection = Networking._connection

onready var Map = get_node('Canvas/Map')
onready var Player = get_node('Canvas/Player')
onready var Loading = get_node('GUI/Loading')
onready var Cursor = get_node('Canvas/Map/Cursor')

const Packets = preload('res://network/Packets.gd')

# Called when the node enters the scene tree for the first time.
func _ready():
	Networking.set_handler(self, 'Game')
	Networking.reconnection_attempts = 0
	
	Loading.set_position(Vector2(OS.window_size.x / 2, OS.window_size.y / 2))

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
			
			Player.set_position(Vector2(player_info.x * 16, player_info.y * 16))
			
			Connection.send_ready()
			
		Packets.Region:
			print('Received region packet!')
			Map.handle_region(data)
			
			Loading.visible = false
			Cursor.visible = true
			
func _process(delta):
	if Connection.has_packet_queue():
		handle_packet(Connection.get_packet_from_queue())
