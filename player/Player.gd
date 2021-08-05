extends Position2D

const Packets = preload('res://network/Packets.gd')
const States = preload('res://player/States.gd')

var Connection = Networking._connection

export var speed = 75

var velocity = Vector2()

var id
var state = States.IDLE
var roll_vector = Vector2.DOWN
var input_vector = Vector2.ZERO
var send_updates = false
var movement_queue = []
var last_target = Vector2.ZERO
var running = false
var idle_animation = 'Idle'
var wait_for_animation = false

var move_up = false
var move_right = false
var move_down = false
var move_left = false

var path = []
var target_point = Vector2.ZERO
# Distance in pixels before target is considered to have arrived at a point
var point_offset = 1

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

func _process(delta):
	if not state == States.MOVE:
		return
	
	var arrived = move_to(target_point)
	
	if arrived:
		path.remove(0)
		
		if len(path) < 1:
			change_state(States.IDLE)
			return
			
		target_point = path[0]	

func change_state(new_state):
	state = new_state
	
	if new_state == States.IDLE:
		animation_state.travel('Idle')
	
	if new_state != States.MOVE:
		return
		
	animation_state.travel('Walk')
		
	if not path or len(path) < 2:
		change_state(States.IDLE)
		return
		
	target_point = path[1]
	
func move_to(pos):
	var mass = 1
	
	var max_speed = (pos - self.position).normalized() * speed
	var steering = max_speed - velocity
	
	velocity += steering / mass
	position += velocity * get_process_delta_time()
	
	set_animations(position.direction_to(pos))
	
	return position.distance_to(pos) < point_offset

func handle_camera(data):
	var opcode = int(data.pop_front())
	
	match opcode:
		Packets.CameraOpcode.Default:
			camera.set_camera_limits()
			
		Packets.CameraOpcode.Lock:
			var limits = data.pop_front()
			
			camera.set_camera_limits(limits.left, limits.top, limits.right, limits.bottom)
	
func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel('Attack')

func add_movement_queue(movement):
	movement_queue.append(movement)

func attack_animation_finished():
	state = States.MOVE

func has_weapon():
	return weapon.texture != null

func get_start_position():
	return Vector2(int(floor(position.x / 16)), int(floor(position.y / 16)))

# i_v = input_vector
func set_animations(i_v):
	animation_tree.set('parameters/Idle/blend_position', i_v)
	animation_tree.set('parameters/Walk/blend_position', i_v)
	animation_tree.set('parameters/Attack/blend_position', i_v)
	
func set_weapon(weapon_info):
	if weapon_info.string == 'null':
		return

	weapon.texture = load('res://sprites/weapons/' + weapon_info.string + '.png')

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
		
func set_path(path):
	self.path = path
	
	change_state(States.MOVE)

