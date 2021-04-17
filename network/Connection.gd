extends Node

const Packets = preload('Packets.gd')

var queue = []

var _networking
var username
var password

func _init(networking):
	self._networking = networking
	
func get_connection():
	return _networking._client.get_peer(1)
	
# Adds packets to a queue, this is useful when transitioning scenes
func add_to_queue(packet):
	queue.append(packet)
	
func get_packet_from_queue():
	return queue.pop_back()
	
func has_packet_queue():
	return len(queue) > 0
	
func handle_utf8(message):
	print('--- handling utf8 ---')
	print(message)
	
func handle_packet(data, utf8 = false):
	if not _networking._handler:
		return
		
	_networking._handler.handle_packet(data, utf8)
	
func send(packet, data):
	var json = JSON.print([packet, data])
	
	get_connection().put_packet(json.to_utf8())

func send_login(email = '', isGuest = false):
	if isGuest:
		send(Packets.Intro, [Packets.IntroOpcode.Guest, 'n', 'n', 'n'])
		return
		
	if email != '':
		send(Packets.Intro, [Packets.IntroOpcode.Register, username, password, email])
		return
		
	send(Packets.Intro, [Packets.IntroOpcode.Login, username, password])
	
func send_ready(map_loaded = false):
	send(Packets.Ready, [true, map_loaded, Networking.GAME_CLIENT])
	
func set_credentials(username_text, password_text):
	username = username_text
	password = password_text
