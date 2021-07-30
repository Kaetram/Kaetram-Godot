extends KinematicBody2D

const Packets = preload('res://network/Packets.gd')
const States = preload('res://player/States.gd')

var Connection = Networking._connection

export var acceleration = 500
export var speed = 80
export var friction = 750

var id
var state = States.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var input_vector = Vector2.ZERO
var send_updates = false
var movement_queue = []
var last_target = Vector2.ZERO
var running = false
var idle_animation = 'Idle'
var wait_for_animation = false

const position_offset = 1

onready var sprite = $PlayerSprite
onready var weapon = $PlayerSprite/Weapon
onready var shadow = $ShadowSprite

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get('parameters/playback')
onready var blink_animation_player = $BlinkAnimationPlayer

onready var camera = $Camera

func _ready():
	randomize()

	animation_tree.active = true

func _physics_process(delta):
	handle_queue()
	
	match state:
		States.ATTACK:
			attack_state()
			
		States.MOVE:
			move_state(delta)

func handle_camera(data):
	var opcode = int(data.pop_front())
	
	match opcode:
		Packets.CameraOpcode.Default:
			camera.set_camera_limits()
			
		Packets.CameraOpcode.Lock:
			var limits = data.pop_front()
			
			camera.set_camera_limits(limits.left, limits.top, limits.right, limits.bottom)

func handle_key_input(x, y):
	# right x: 1, y: 0
	# left: x: -1, y: 0
	# up: x: 0, y: -1
	# down: x: 0, y: 1
	
	if len(movement_queue) > 0:
		return
		
	if x == 1 and y == 0:
		move_right()
	elif x == -1 and y == 0:
		move_left()
	elif x == 0 and y == -1:
		move_up()
	elif x == 0 and y == 1:
		move_down()
	
	print('x: ' + str(x) + ' y: ' + str(y))

func move_up():
	movement_queue.append(Vector2(position.x, position.y - 16))
	
func move_down():
	movement_queue.append(Vector2(position.x, position.y + 16))
	
func move_left():
	movement_queue.append(Vector2(position.x - 16, position.y))
	
func move_right():
	movement_queue.append(Vector2(position.x + 16, position.y))

func handle_queue():
	
	if position.distance_to(last_target) < position_offset and last_target != Vector2.ZERO:
		input_vector = Vector2.ZERO
		last_target = Vector2.ZERO
	
	if len(movement_queue) > 0:
		var movement = movement_queue.pop_front()
		
		input_vector = position.direction_to(movement)
		
		last_target = movement
	
				
func set_input_vector(x, y):
	input_vector.x = x
	input_vector.y = y
	
	input_vector = input_vector.normalized()
	
func set_attack_state(attack_state):
	set_input_vector(roll_vector.x, roll_vector.y)
	
	if has_weapon():
		state = attack_state
	else:
		state = States.FIST_ATTACK
		
	if send_updates:
		Connection.send_attack(id, state)
	
func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel('Attack')

func add_movement_queue(movement):
	movement_queue.append(movement)

func move_state(delta):
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		
		set_animations(input_vector)
		
		# TODO - Dynamic speed
		#speed = 80
		animation_state.travel('Walk')
		
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		animation_state.travel(idle_animation)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move()

# i_v = input_vector
func set_animations(i_v):
	animation_tree.set('parameters/Idle/blend_position', i_v)
	animation_tree.set('parameters/Walk/blend_position', i_v)
	animation_tree.set('parameters/Attack/blend_position', i_v)
	
func set_weapon(weapon_info):
	if weapon_info.string == 'null':
		return

	weapon.texture = load('res://sprites/weapons/' + weapon_info.string + '.png')

func move():
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, PI/4, false)

func attack_animation_finished():
	state = States.MOVE

func has_weapon():
	return weapon.texture != null

