extends KinematicBody2D

const Packets = preload('res://network/Packets.gd')
const States = preload('res://player/States.gd')

var direction: Vector2 = Vector2.ZERO

var pixels_per_second: float = 4 * 16 # TODO - Not make this hardcoded
var step_size: float = 1 / pixels_per_second

var step: float = 0

var pixels_moved: int = 0

var Connection = Networking._connection

var velocity = Vector2.ZERO

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
var new_target_point = Vector2.ZERO

# Distance in pixels before target is considered to have arrived at a point
var point_offset = 3

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
	if target_point == Vector2.ZERO:
		return
	
	direction = position.direction_to(target_point)
	
	if not is_moving(): 
		return
	
	step += delta
	
	if step < step_size:
		return
		
	step -= step_size
	pixels_moved += 1
	
	move_and_collide(direction)
	
	if pixels_moved >= 16:
		direction = Vector2.ZERO
		pixels_moved = 0
		step = 0
		
		path.remove(0)
		
		if len(path) > 0:
			target_point = path[0]
			
			set_animations(position.direction_to(target_point))
		else:
			change_state(States.IDLE)
	
func is_moving() -> bool:
	return direction.x != 0 or direction.y != 0

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
	
	path.remove(0)
	target_point = path[0]
	
	set_animations(position.direction_to(target_point))

func handle_key_input(x, y):
	if x == y or (x != 0 and y != 0):
		return
	
	var start_position = get_start_position()
	var end_position = start_position + Vector2(x, y)
	
	var path = Astar.find_path(start_position, end_position)
	
	set_path(path)
	
	if x > 0 and y == 0: # Right
		print('Right?')
	elif x < 0 and y == 0: # Down
		print('Left?')
	elif x == 0 and y > 0: # Down
		print('Up')
	elif x == 0 and y < 0: # Up
		print('Down')

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

