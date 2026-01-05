extends Node2D

@onready var spawner = $Path2D/Spawner
@onready var start_btn = $Button
@onready var player = $"Slingshot"

func _process(delta):

	# Если нажата кнопка
	if start_btn.is_pressed_flag:
		start_btn.is_pressed_flag = false
		spawner.start_spawner()

	# Если игрок умер
	if player.is_dead:
		player.is_dead = false
		player.hp=3
		spawner.stop_spawner()
		start_btn.visible = true
