extends Area2D

# --- Настройки ---
@export var birds_with_probabilities: Array[Dictionary] = []
@export var max_pull_distance: float = 200.0
@export var launch_multiplier: float = 5.0

var current_bird: RigidBody2D = null
var dragging = false
var can_start_drag =false
@onready var center=get_node("CenterOfSlingshot")

@export var hp = 3
var is_dead := false

func die():
	is_dead = true
	
func _ready():
	_load_bird_config("res://scripts/projectiles/birds_config.json")
	await get_tree().create_timer(0.1).timeout
	_spawn_next_bird()
	
func _physics_process(delta):
	if is_dead:
		return
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is CharacterBody2D:
			hp -= body.hit_player()
			if hp<= 0:
				die()
			
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# начать drag только если мышь нажата и позиция близко к птице
		if event.pressed and can_start_drag and current_bird:
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
	if is_dead:
		hp = 3
		
func _drag_bird():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - center.global_position
	if dir.length() > max_pull_distance:
		dir = dir.normalized() * max_pull_distance
	current_bird.global_position = center.global_position + dir

func _launch_bird():
	current_bird.set_collision_mask_value(4, true)
	current_bird.set_collision_layer_value(3, true)
	if not current_bird:
		return
	var impulse_dir = -(current_bird.global_position - center.global_position)
	var impulse = impulse_dir * launch_multiplier
	current_bird.apply_impulse(impulse)

	current_bird = null

	await get_tree().create_timer(0.5).timeout
	_spawn_next_bird()

func _spawn_next_bird():
	var next_scene: PackedScene = _choose_random_bird()
	if next_scene==null:
		print("Все птицы выпущены!")
		return
	var bird_instance: RigidBody2D = next_scene.instantiate()

	bird_instance.global_position = center.global_position
	
	current_bird = bird_instance
	get_tree().current_scene.add_child(current_bird)
	dragging = false
	can_start_drag = true
	current_bird.set_collision_mask_value(4, false)
	current_bird.set_collision_layer_value(3, false)

func _choose_random_bird() -> PackedScene:
	var total := 0.0
	for entry in birds_with_probabilities:
		total += entry["chance"]
	
	var pick = randf() * total
	var cum = 0.0
	
	for entry in birds_with_probabilities:
		cum += entry["chance"]
		if pick <= cum:
			return entry["scene"]
	
	return birds_with_probabilities[0]["scene"]

func _load_bird_config(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Не удалось открыть файл: " + path)
		return
	
	var json_text = file.get_as_text()
	file.close()

	# Парсим JSON — здесь JSON.parse_string возвращает сразу Variant (Array/Dictionary) или null
	var parsed = JSON.parse_string(json_text)
	if parsed == null:
		push_error("Не удалось распарсить JSON: " + path)
		return
	
	# parsed должен быть массив
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Ожидался Array в JSON: " + path)
		return

	for entry in parsed:
		# Проверяем что это словарь и содержит нужные поля
		if typeof(entry) == TYPE_DICTIONARY and entry.has("scene") and entry.has("chance"):
			var scene_path : String = entry["scene"]
			var chance : float = float(entry["chance"])
			
			if scene_path != "" and chance > 0.0:
				var scene : PackedScene = load(scene_path)
				if scene:
					birds_with_probabilities.append({
						"scene": scene,
						"chance": chance
					})
				else:
					push_error("Не удалось load() сцену: " + scene_path)
			else:
				push_error("Неправильные значения scene/chance в JSON")
		else:
			push_error("Неправильный формат записи в JSON")
