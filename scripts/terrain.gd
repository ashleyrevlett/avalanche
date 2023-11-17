extends Node2D

@export var angle: float = -10
@export var ground_scene: PackedScene

@onready var camera: Camera2D = %Camera2D
@onready var ground_width: float
@onready var ground_height: float

var ground_objects = []

var camera_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_size = get_viewport_rect().size # * camera.zoom
	rotation_degrees = angle
	for x in range(1, 4):
		_spawn_ground()	
	# get visible camera rect
	# spawn series of ground objects in a line, starting from the bottom left corner of rect


func _spawn_ground():
	print("spawned ground!")
	var instance = ground_scene.instantiate()
	if (ground_objects.size() == 0):
		instance.position = Vector2(-180, 370)
		ground_width = instance.width
		ground_height = instance.height
	else:
		var last_ground = ground_objects[-1]
		var new_pos = last_ground.position + Vector2(ground_width, 0)
		instance.position = new_pos
	ground_objects.append(instance)
	add_child(instance)
	print("ground_objects:", ground_objects)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# when the first ground goes offscreen, remove it and add a new one
	# get global pos of instance, compare to camera rect
	if (ground_objects.size() > 0):
		var first_pos = ground_objects[0].global_position
		var camera_rect = Rect2(camera.get_screen_center_position() - camera_size / 2, camera_size)
		if (first_pos.x + ground_width/2 < camera_rect.position.x - ground_width/2):
			print("offscreen!")
			var instance = ground_objects.pop_front()
			instance.queue_free()
			print("removed ground!")
			_spawn_ground()
	
	# when the camera comes within X of the end of the existing ground objects, 
	# spawn some more
