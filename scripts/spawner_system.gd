extends Node2D

@onready var camera: Camera2D = %Camera2D

@export var spawner_scene: PackedScene

var camera_size: Vector2
var objects = []


func _ready():
	camera_size = get_viewport_rect().size # * camera.zoom
	for x in range(1, 4):
		_spawn()	


func _spawn():
	var instance = spawner_scene.instantiate()
	if (objects.size() == 0):
		instance.position = Vector2(0, 0)
	else:
		var random_x = randi_range(camera_size.x/10, camera_size.x/2)
		var new_pos = objects[-1].position + Vector2(random_x, -camera_size.y/7)
		instance.position = new_pos
	add_child(instance)
	objects.append(instance)
	

func _process(delta):
	if (objects.size() > 0):
		var first_pos = objects[0].global_position
		var camera_rect = Rect2(camera.get_screen_center_position() - camera_size / 2, camera_size)
		if (first_pos.x < camera_rect.position.x - 100):
			objects.pop_front().queue_free()
			_spawn()
