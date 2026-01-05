@abstract
extends RigidBody2D

# Общие параметры для всех птиц:
@export var damage: float = 10.0
@export var speed_multiplier: float = 1.0
@export var special_cooldown: float = 0.0

func _ready():
	# Можно сделать начальные установки, анимации и т.д.
	pass

# Абстрактный метод — каждая птица реализует по-своему
@abstract func on_hit()
