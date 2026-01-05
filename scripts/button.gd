extends Button

var is_pressed_flag := false

func _ready():
	text = "Start"

func _pressed():
	is_pressed_flag = true
	visible = false
