@abstract
extends Node

#Это абстрактный класс для всех врагов(если делать будем ещё)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@abstract func take_damage()
