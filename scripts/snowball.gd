extends RigidBody2D

@onready var sprite: Sprite2D = %Sprite2D
var radius: float
var camera: Camera2D

enum Size {EXTRA_SMALL, SMALL, MEDIUM, LARGE, EXTRA_LARGE}

func _ready():
	camera = get_tree().get_first_node_in_group("camera")
	# true random
	#var r = Size.keys()[randi() % Size.keys().size()]
	
	var r: Size
	match randi() % 10:
		1,2,3: r = Size.EXTRA_SMALL
		4,5,6: r = Size.SMALL
		7,8: r = Size.MEDIUM
		9: r = Size.LARGE
		0: r = Size.EXTRA_LARGE
		
	print(r)
	if r == Size.EXTRA_SMALL:
		radius = 32 # 32 px wide
		mass = 0.1
		sprite.frame = 4
	elif r == Size.SMALL:	
		radius = 64
		mass = .2
		sprite.frame = 3
	elif r == Size.MEDIUM:
		radius = 132
		mass = 0.4
		sprite.frame = 2
	elif r == Size.LARGE:
		radius = 164
		mass = 0.8
		sprite.frame = 1
	elif r == Size.EXTRA_LARGE:
		radius = 194
		mass = 1.2
		sprite.frame = 0

	_update_display()


func _process(delta):
	pass
	"""
	var left_frame_x = camera.camera_rect.position.x - camera.camera_rect.size.x / 2
	if (global_position.x + max_radius < left_frame_x):
		print("removing snowball!")
		queue_free()
	"""


func _update_display():
	%CollisionShape2D.shape.radius = radius
