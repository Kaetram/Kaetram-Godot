extends Node

const GAME_CLIENT = 'Kaetram_Open_GoDot'
const GAME_URL = 'ws://127.0.0.1:9000'

const Packets = preload('Packets.gd')
const Connection = preload('Connection.gd')

var _client = WebSocketClient.new()
var _connection = Connection.new(self)

var signal_created = false
var in_game = false
var development = false

var reconnection_attempts = 0
var reconnection_threshold = 30


var _handler

func _ready():
	pass

func create_connection():
	if has_connection():
		return
		
	if not signal_created:
		_client.connect('connection_closed', self, '_on_closed')
		_client.connect('connection_error', self, '_on_error')
		_client.connect('connection_established', self, '_on_connected')
		_client.connect('data_received', self, '_on_data')
		
		signal_created = true

	var status = _client.connect_to_url(GAME_URL)

	if status != OK:
		push_error('Unable to connect.')
		
	return status
		
		
func _on_closed(was_clean = false):
	print('Connection closed, clean: ' + str(was_clean))
	
	if not was_clean:
		while reconnection_attempts < reconnection_threshold:
			if not in_game or has_connection():
				reconnection_attempts = 0
				return
				
			print('Attempting to Reconnect...')
			
			yield(get_tree().create_timer(1), 'timeout')
			
			create_connection()
			
			reconnection_attempts += 1
			
	if not in_game:
		return
	
	return get_tree().change_scene('res://scenes/Login.tscn')

func _on_error():
	print('An error has occurred while trying to connect.')
	
	if _handler.get('error_message'):
		_handler.set_error_message('Could not connect to server.')

func _on_connected(protocol = ''):
	print('Successfully connected with protocol: ' + protocol)

func _on_data():
	var packet_string = _client.get_peer(1).get_packet().get_string_from_utf8()
	
	if packet_string[0] != '[':
		_connection.handle_packet(packet_string, true)
	else:
		var data = JSON.parse(packet_string).result
		
		if not data:
			return
			
		for i in data:
			_connection.handle_packet(i)
			
func set_handler(handler, name):
	_handler = handler
	
	in_game = name == 'Game'
	
	print('Networking handler updated to ' + name);
	
func set_development(status = false):
	development = status
	
	reconnection_threshold = 1

func has_connection():
	return _client.get_connection_status() == 2
	
func get_reconnection_timeout():
	return reconnection_threshold - reconnection_attempts

func get_reconnection_text():
	return 'Connection Lost - Timeout in ' + str(get_reconnection_timeout()) + ' seconds'

func _process(_delta):
	_client.poll()
