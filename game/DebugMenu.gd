extends Control

var style = StyleBoxFlat.new()

func _ready():
	style.set_bg_color(Color(1, 1, 1, 0.25))
	
	set('custom_styles/normal', style)

func _on_vector_pressed():
	print('hello button does something')
