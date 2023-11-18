extends Node2D

@export var angle: float = -10
@export var ground_scene: PackedScene
@export var spawner_scene: PackedScene

@onready var camera: Camera2D = %Camera2D
@onready var ground_width: float
@onready var ground_height: float

var ground_objects = []
var spawner_objects = []


func _ready():
	rotation_degrees = angle
	for x in range(1, 8):
		_spawn_ground()	
		_spawn_spawner()


func _spawn_spawner():
	var instance = spawner_scene.instantiate()
	if (spawner_objects.size() == 0):
		instance.position = Vector2(camera.camera_size.x/2, 0)
	else:
		var random_x = randi_range(camera.camera_size.x * .6, camera.camera_size.x * 1.2)
		var random_y = randi_range(0, camera.camera_size.y/3)
		var new_pos = spawner_objects[-1].position + Vector2(random_x, random_y * -1)
		print("spawned at ", Vector2(random_x, random_y), new_pos)
		instance.position = new_pos
	add_child(instance)
	spawner_objects.append(instance)
	

func _spawn_ground():
	var instance = ground_scene.instantiate()
	if (ground_objects.size() == 0):
		instance.position = Vector2(-980, 370)
		ground_width = instance.width
		ground_height = instance.height
	else:
		var last_ground = ground_objects[-1]
		var new_pos = last_ground.position + Vector2(ground_width, 0)
		instance.position = new_pos
	ground_objects.append(instance)
	add_child(instance)
	

func _process(delta):
	# when the first ground goes offscreen, remove it and add a new one
	# get global pos of instance, compare to camera rect
	
	if (ground_objects.size() > 0):
		var first_pos = ground_objects[0].global_position
		if (first_pos.x + ground_width/2 < camera.camera_rect.position.x - ground_width*2):
			var instance = ground_objects.pop_front()
			instance.queue_free()
			_spawn_ground()
	
		var last_pos = ground_objects[-1].global_position
		var angle_modifier = deg_to_rad(floor(last_pos.y / 10000))
		var new_rad = deg_to_rad(angle) + angle_modifier
		var new_rot = lerp_angle(rotation, new_rad, 2.5 * delta)
		rotation = new_rot

	if (spawner_objects.size() > 0):
		var first_pos = spawner_objects[0].global_position
		#print(first_pos.x, camera_rect.position.x)
		if (first_pos.x < camera.camera_rect.position.x - camera.camera_size.x):
			var instance = spawner_objects.pop_front()
			# print("removing spawner")
			instance.queue_free()
			_spawn_spawner()
