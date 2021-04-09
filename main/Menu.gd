extends Node

onready var Menu = get_node('Menu')
onready var Background = get_node('Background')

func _ready():
	
	_on_size_changed()
	
	return get_tree().get_root().connect('size_changed', self, '_on_size_changed')
	
func get_screen_size():
	return Vector2(OS.window_size.x, OS.window_size.y)
	
func _on_size_changed():
	Background.set_size(get_screen_size())
	Menu.set_size(get_screen_size())
