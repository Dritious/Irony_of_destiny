@abstract
extends RigidBody2D

# Общие параметры для всех птиц:
@export var speed_multiplier: float = 1.0
@export var special_cooldown: float = 0.0
var damage = 0

func _ready():
	contact_monitor = true
	max_contacts_reported = 10

func _physics_process(delta: float) -> void:
	var contacts = get_colliding_bodies()
	for body:RigidBody2D in contacts:
		if body.collision_layer == 2:
			on_hit(damage)
			body.take_damge(damage)
	# проверка конкретного слоя
	
		
# Абстрактный метод — каждая птица реализует по-своему
@abstract func on_hit(damage) -> void
