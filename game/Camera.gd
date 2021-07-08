extends Camera2D

const LIMIT_LEFT = 0
const LIMIT_TOP = 0
const LIMIT_RIGHT = 8192
const LIMIT_BOTTOM = 8192

const MAX_ZOOM = Vector2(0.45, 0.45)
const MIN_ZOOM = Vector2(0.2, 0.2)

func _ready():  
	set_process_input(true)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_PLUS:
					zoom_in()
					
				KEY_EQUAL:
					zoom_in()

				KEY_MINUS:
					zoom_out()

func zoom_in():
	var zoom = self.get_zoom()
	self.update_zoom(Vector2(float(zoom.x - 0.01), float(zoom.y - 0.01)))

func zoom_out():
	var zoom = self.get_zoom()
	self.update_zoom(Vector2(float(zoom.x + 0.01), float(zoom.y + 0.01)))

func set_camera_limits(left = LIMIT_LEFT, top = LIMIT_TOP, right = LIMIT_RIGHT, bottom = LIMIT_BOTTOM):
	set_limit(MARGIN_LEFT, left)
	set_limit(MARGIN_TOP, top)
	set_limit(MARGIN_RIGHT, right)
	set_limit(MARGIN_BOTTOM, bottom)

func update_zoom(zoom_vector):
	if zoom_vector >= MAX_ZOOM or zoom_vector <= MIN_ZOOM:
		return
	
	self.set_zoom(zoom_vector)
