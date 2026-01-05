@abstract
extends RigidBody2D

# Общие параметры для всех птиц:
@export var speed_multiplier: float = 1.0
@export var special_cooldown: float = 0.0

func _ready():
	pass

func _physics_process(delta: float) -> void:
	var contacts = get_colliding_bodies()
	for body in contacts:
		print(body.collision_layer)
		if body.collision_layer == 4:
			body.take_damage(on_hit())
	# проверка конкретного слоя
	
		
# Абстрактный метод — каждая птица реализует по-своему
@abstract func on_hit() -> int
