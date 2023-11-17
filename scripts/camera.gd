extends Camera2D

@export var move_speed = 60

var move_direction = Vector2.ZERO

var can_move = false

func _ready():
	move_direction = _get_move_direction()
	
	await get_tree().create_timer(1).timeout
	print("after timeour")
	can_move = true



func _process(delta):
	if can_move:
		position += move_direction * delta * move_speed


func _get_move_direction():
	var degrees = -10.0
	var radians = degrees * PI/180.0
	var run = 1.0
	var rise = tan(radians) * run
	return Vector2(run, rise)
