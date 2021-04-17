extends Node

var regex = RegEx.new()
var Connection = Networking._connection

const Packets = preload('res://network/Packets.gd')

onready var Menu = get_node('Menu')
onready var Background = get_node('Background')

onready var username_field = get_node('Menu/Title Screen/Username')
onready var password_field = get_node('Menu/Title Screen/Password')
onready var password_confirm_field = get_node('Menu/Title Screen/Password Confirmation')
onready var email_field = get_node('Menu/Title Screen/Email')

onready var remmember_me = get_node('Menu/Title Screen/Remmember Me')
onready var error_message = get_node('Menu/Title Screen/Error Message')

func _ready():
	Networking.set_handler(self, 'Main Menu')
	
	regex.compile('^[a-z0-9]+[\\._]?[a-z0-9]+[@]\\w+[.]\\w{2,3}$')
	
	_on_size_changed()
	
	return get_tree().get_root().connect('size_changed', self, '_on_size_changed')

func start_game():
	set_error_message()
	
	if not verify_fields():
		return
	
	Networking.create_connection()
	
# --------- Handler Section ---------

func handle_handshake(info):
	Connection.set_credentials(username_field.text, password_field.text)
	
	if 'development' in info:
		Networking.set_development(info.development)
	
	Connection.send_login(email_field.text if is_registering() else '')
	
func handle_utf8(utf8):
	match utf8:
		'updated':
			set_error_message('The client has been updated!')

		'full':
			set_error_message('The servers are currently full!')
			
		'error':
			set_error_message('The server has responded with an error!')
			
		'development':
			set_error_message('The game is currently in development mode.')
			
		'disallowed':
			set_error_message('The server is currently not accepting connection.')
			
		'maintenance':
			set_error_message('The game is currently under maintenance.')

		'userexists':
			set_error_message('The username you have chosen already exists.')

		'emailexists':
			set_error_message('The email you have chosen is not available.')
			
		'loggedin':
			set_error_message('The player is already logged in!')
			
		'invalidlogin':
			set_error_message('You have entered the wrong username or password.')
			
		'toofast':
			set_error_message('You are trying to log in too fast from the same connection.')
			
		'timeout':
			set_error_message('You have been disconnected for being inactive too long.')
			
		_:
			set_error_message('An unknown error has occurred, please submit a bug report.')

func handle_packet(data, utf8 = false):
	if utf8:
		handle_utf8(data)
		return
		
	var packet_id = int(data[0])
	
	match packet_id:
		Packets.Handshake:
			if len(data) > 1:
				handle_handshake(data[1])
				
		Packets.Welcome:
			Connection.add_to_queue(data)
			
			if is_remmember_me():
				save_info()
			else:
				clear_info()
			
			return get_tree().change_scene('res://scenes/Game.tscn')
			
		_:
			Connection.add_to_queue(data)

# --------- Save/Load Functions ---------

func save_info():
	var config = ConfigFile.new()
	
	config.set_value('info', 'username', username_field.text)
	config.set_value('info', 'password', password_field.text)
	config.set_value('info', 'remmember_me', is_remmember_me())
	
	config.save_encrypted_pass(Globals.config_path, Globals.encrypt_password)
	
	print('Saved config info.')
	
func load_info():
	if is_registering():
		return
	
	var config = ConfigFile.new()
	var error = config.load_encrypted_pass(Globals.config_path, Globals.encrypt_password)
	
	if error != 0:
		if error != 7: # If it's something different than "file not found"
			print('An error has occurred while trying to load config file.')
		return
	
	username_field.text = config.get_value('info', 'username')
	username_field.text = config.get_value('info', 'password')
	
	remmember_me.set_pressed(config.get_value('info', 'remmember_me'))

func clear_info():
	var directory = Directory.new()
	
	directory.remove(Globals.config_path)

# --------- Setters Section ---------

func set_error_message(message = ''):
	error_message.text = message


# --------- Getters and Verifiers Section ---------

func is_registering():
	return get_tree().get_current_scene().get_name() == 'New Account'
	
func is_remmember_me():
	return remmember_me.is_pressed()
	
func get_screen_size():
	return Vector2(OS.window_size.x, OS.window_size.y)
	
func verify_fields():
	if len(username_field.text) < 1:
		set_error_message('Please enter a valid username.')
		return false
		
	if len(password_field.text) < 1:
		set_error_message('Please enter a valid password.')
		return false
		
	if is_registering():
		if password_field.text != password_confirm_field.text:
			set_error_message('The passwords you have entered do not match.')
			return false
			
		var email_result = regex.search(email_field.text)
		
		if not email_result:
			set_error_message('The email address you have entered is not valid.')
			return false
		
	return true

# --------- Signals Section --------- #
	
func _on_size_changed():
	Background.set_size(get_screen_size())
	Menu.set_size(get_screen_size())

func _on_username_entered(new_text):
	password_field.grab_focus()
	
func _on_password_entered(new_text):
	if is_registering():
		password_confirm_field.grab_focus()
	else:
		start_game()

func _on_password_confirm_entered(new_text):
	email_field.grab_focus()
	
func _on_email_entered(new_text):
	start_game()

func _on_login_pressed():
	start_game()

func _on_new_account_pressed():
	return get_tree().change_scene('res://scenes/New Account.tscn')

func _on_cancel_pressed():
	return get_tree().change_scene('res://scenes/Login.tscn')
