extends "res://scripts/enemies/AbstractEnemy.gd"


@export var health = 300
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <=0:
		queue_free()

#Это функция Севы, её не трожь
func take_damage(damage):
	health-=damage

@export var patrol_path: NodePath
@export var speed: float = 100.0

var patrol_points: Array = []
var patrol_index: int = 0

func _ready():
	var path = get_parent() as Path2D
	# Получаем массив точек кривой
	patrol_points = path.curve.get_baked_points()

func _physics_process(delta):
	var target = patrol_points[patrol_index]
	
	# Расстояние до цели
	if global_position.distance_to(target) < 4:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		target = patrol_points[patrol_index]

	# Направление к точке
	var dir = (target - global_position).normalized()
	
	velocity = dir * speed
	move_and_slide()
