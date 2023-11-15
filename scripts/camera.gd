extends Camera2D

@export var move_speed = 35.0
@export var move_direction = Vector2(1.0, -0.3)


func _process(delta):
	position += move_direction * delta * move_speed
