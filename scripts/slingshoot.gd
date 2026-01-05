extends Node2D

@export var max_radius: float = 150.0   # макс. длина растяжения
@export var launch_force: float = 15.0  # множитель силы

var dragging: bool = false

@onready var center = $"res://scenes/slingshot/Center_of_slingshot.tscn"
@onready var projectile = $"res://scenes/projectiles/Olivie.tscn"

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
				# Начинаем тянуть если кликнули близко к птице
			var dist = (get_global_mouse_position() - projectile.global_position).length()
			if dist < 30:
				dragging = true
				#projectile.mode = RigidBody2D.MODE_CHARACTER  # отключаем физику на время тащения
			else:
				if dragging:
					_shoot()
					dragging = false

func _process(delta):
	if dragging:
		_drag_projectile()

func _drag_projectile():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - center.global_position

	# Ограничиваем растяжение радиусом
	if dir.length() > max_radius:
		dir = dir.normalized() * max_radius

	# Передвигаем птицу
	projectile.global_position = center.global_position + dir

func _shoot():
	# Снова включаем физику
	#projectile.mode = RigidBody2D.MODE_RIGID

	# Импульс: направлен от растянутой позиции к центру (отталкивание)
	var dir = center.global_position - projectile.global_position
	var impulse = dir * launch_force

	projectile.apply_impulse(Vector2.ZERO, impulse)

	# Можно отключить скрипт перетаскивания, если птица уже вылетела
	set_process(false)
