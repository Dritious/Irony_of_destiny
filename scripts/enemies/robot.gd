extends "res://scripts/enemies/AbstractEnemy.gd"


@export var health = 300
@export var enemy_damage = 1
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <=0:
		queue_free()

#Это функция Севы, её не трожь
func take_damage(damage):
	health-=damage
	
func hit_player():
	queue_free()
	return enemy_damage
	
@export var patrol_path: NodePath
@export var speed: float = 100.0

var path_curve: Curve2D
var distance_travelled: float = 0.0
var path_length: float = 0.0


func _ready():
	var path = get_parent() as Path2D
	path_curve = path.curve
	path_length = path_curve.get_baked_length()

func _physics_process(delta):
	# Двигаемся по пути по расстоянию
	distance_travelled += speed * delta
	
	# Зациклили путь
	if distance_travelled > path_length:
		distance_travelled = 0

	# Получаем позицию на кривой по расстоянию
	var target_pos = path_curve.sample_baked(distance_travelled, true)
	
	# Направление к следующей точке
	var dir = (target_pos - global_position)
	
	# Если цель близко, не телепортировать
	if dir.length() > 1:
		velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
