extends Node2D

@export var enemy_scene: PackedScene

# Тайминги спавна
@export var spawn_time_start := 2.0
@export var spawn_time_min := 0.4
@export var spawn_time_decrease := 0.05

# Лимит врагов
@export var max_enemies_start := 5
@export var max_enemies_increase := 1
@export var max_enemies_limit := 50

# Как часто усложняется игра (в секундах)
@export var difficulty_step_time := 10.0

var current_spawn_time: float
var current_max_enemies: int

var spawn_timer: Timer
var difficulty_timer: Timer

var is_active := false
var need_reset := false

func _ready():
	current_spawn_time = spawn_time_start
	current_max_enemies = max_enemies_start

	# Таймер спавна
	spawn_timer = Timer.new()
	spawn_timer.wait_time = current_spawn_time
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_enemy)
	add_child(spawn_timer)
	# Таймер усложнения
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = difficulty_step_time
	difficulty_timer.timeout.connect(_increase_difficulty)
	add_child(difficulty_timer)


func start_spawner():
	if is_active:
		return
	is_active = true
	need_reset = true

func stop_spawner():
	is_active = false

func reset_enemies():
	var parent_node := get_parent()
	for child in parent_node.get_children():
		if child is CharacterBody2D:
			child.queue_free()

func _spawn_enemy():
	if _get_enemy_count() >= current_max_enemies:
		return

	var path := get_parent() as Path2D
	if path == null:
		return

	var enemy := enemy_scene.instantiate()
	enemy.position=position
	path.add_child(enemy)


func _increase_difficulty():
	# Уменьшаем интервал спавна
	current_spawn_time = max(
		spawn_time_min,
		current_spawn_time - spawn_time_decrease
	)
	spawn_timer.wait_time = current_spawn_time

	# Увеличиваем лимит врагов
	current_max_enemies = min(
		max_enemies_limit,
		current_max_enemies + max_enemies_increase
	)


func _get_enemy_count() -> int:
	var count := 0
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			count += 1
	return count

func _process(delta):
	if is_active:
		if not spawn_timer.is_stopped():
			# Уже запущено
			pass
		else:
			# Запустить таймеры
			if need_reset:
				_reset_state()
			spawn_timer.start()
			difficulty_timer.start()

		# Таймер спавна
		if spawn_timer.time_left <= 0:
			_spawn_enemy()
			spawn_timer.wait_time = current_spawn_time
			spawn_timer.start()

		# Таймер усложнения
		if difficulty_timer.time_left <= 0:
			_increase_difficulty()
			difficulty_timer.start()
	else:
		if not spawn_timer.is_stopped():
			spawn_timer.stop()
			difficulty_timer.stop()

func _reset_state():
	# Сброс параметров и врагов
	reset_enemies()
	current_spawn_time = spawn_time_start
	current_max_enemies = max_enemies_start
	spawn_timer.wait_time = current_spawn_time
	difficulty_timer.wait_time = difficulty_step_time
	need_reset = false
