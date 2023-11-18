extends Camera2D

@export var camera_rect: Rect2
@export var camera_size: Vector2


"""
@export var move_speed = 60
var move_direction = Vector2.ZERO
var can_move = false
"""
func _ready():
	"""
	move_direction = _get_move_direction()
	
	await get_tree().create_timer(1).timeout
	print("after timeour")
	can_move = true
	"""
	camera_size = get_viewport_rect().size * zoom # * camera.zoom
	camera_rect = Rect2(get_screen_center_position() - camera_size / 2, camera_size)
	


func _process(delta):
	"""
	if can_move:
		position += move_direction * delta * move_speed
	"""
	camera_rect = Rect2(get_screen_center_position() - camera_size / 2, camera_size)


"""
func _get_move_direction():
	var degrees = -10.0
	var radians = degrees * PI/180.0
	var run = 1.0
	var rise = tan(radians) * run
	return Vector2(run, rise)
"""
