extends Node2D

# --- Настройки ---
@export var bird_scenes: Array[PackedScene] = []
@export var max_pull_distance: float = 200.0
@export var launch_multiplier: float = 5.0

# --- Данные ---
var birds_queue: Array[PackedScene] = []
var current_bird: RigidBody2D = null
var dragging = false
var can_start_drag =false
@onready var center=get_node("CenterOfSlingshot")

func _ready():
	birds_queue = bird_scenes.duplicate()
	birds_queue.shuffle()
	await get_tree().create_timer(0.1).timeout
	_spawn_next_bird()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# начать drag только если мышь нажата и позиция близко к птице
		if event.pressed and can_start_drag:
			var dist = (get_global_mouse_position() - current_bird.global_position).length()
			if dist < 30:
				dragging = true
				can_start_drag = false
		# когда мышь отпущена и мы действительно drag’им — стрелять
		elif !event.pressed and dragging and !can_start_drag:
			_launch_bird()
			dragging = false

func _process(_delta):
	if dragging and current_bird:
		_drag_bird()
		
func _drag_bird():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - center.global_position
	if dir.length() > max_pull_distance:
		dir = dir.normalized() * max_pull_distance
	current_bird.global_position = center.global_position + dir

func _launch_bird():
	if not current_bird:
		return
	var impulse_dir = -(current_bird.global_position - center.global_position)
	var impulse = impulse_dir * launch_multiplier
	current_bird.apply_impulse(impulse)

	current_bird = null

	await get_tree().create_timer(0.5).timeout
	_spawn_next_bird()

func _spawn_next_bird():
	var next_scene: PackedScene = birds_queue.pop_front()
	if next_scene==null:
		print("Все птицы выпущены!")
		return
	var bird_instance: RigidBody2D = next_scene.instantiate()

	bird_instance.global_position = center.global_position
	
	current_bird = bird_instance
	get_tree().current_scene.add_child(current_bird)
	dragging = false
	can_start_drag = true
