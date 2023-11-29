extends Node2D

@export var angle: float = 3
@export var max_angle: float = 15
@export var rotation_speed: float = 1
@export var ground_scene: PackedScene
@export var spawner_scene: PackedScene

@onready var camera: Camera2D = %Camera2D
@onready var ground_width: float
@onready var ground_height: float

var ground_objects = []
var spawner_objects = []


func _ready():
	rotation_degrees = -angle
	
	for x in range(1, 8):
		_spawn_ground()
	
	for x in range(1, 4):
		_spawn_spawner()
	

func _spawn_spawner():
	var instance = spawner_scene.instantiate()
	var y_pos = 0
	if (spawner_objects.size() == 0):
		instance.position = Vector2(camera.camera_rect.end.x, y_pos)
		print(instance.position, ":", camera.camera_rect)
	else:
		# position this spawner to the right of the last one, 
		# plus approximately the camera frame's width
		var random_x = randi_range(camera.camera_rect.size.x * .2, camera.camera_rect.size.x * .5)
		var new_pos = Vector2(spawner_objects[-1].position.x + random_x, y_pos)
		instance.position = new_pos
	add_child(instance)
	spawner_objects.append(instance)
	

func _spawn_ground():
	var instance = ground_scene.instantiate()
	if (ground_objects.size() == 0):
		ground_width = instance.width
		ground_height = instance.height
		instance.position = Vector2(-ground_width, ground_height/2)

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
		if (first_pos.x + ground_width/2 < camera.camera_rect.position.x - ground_width/2):
			var instance = ground_objects.pop_front()
			instance.queue_free()
			_spawn_ground()
	
		var last_pos = ground_objects[-1].global_position
		var a = floor(last_pos.x / 1500)
		var new_angle = -clamp(a, angle, max_angle)
		var new_rad = deg_to_rad(new_angle)
		#print("a: ", int(a), " : ", new_angle, " : ", new_rad)
		if new_rad != rotation:
			var new_rot = lerp_angle(rotation, new_rad, rotation_speed * delta)
			rotation = new_rot
		
	# once a spawner appears on screen, remove it and add a new one
	if (spawner_objects.size() > 0):
		var first_pos = spawner_objects[0].global_position
		if (first_pos.x < camera.camera_rect.end.x):
			var instance = spawner_objects.pop_front()
			#print("removing spawner")
			#instance.queue_free()
			_spawn_spawner()
