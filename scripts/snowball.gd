extends RigidBody2D

@onready var sprite: Sprite2D = %Sprite2D
var grow_speed: float = 80.0
var melt_speed: float = 120.0
var start_radius: float = 1.0
var radius: float # target size
var camera: Camera2D
var melting: bool = false

enum Size {EXTRA_SMALL, SMALL, MEDIUM, LARGE, EXTRA_LARGE}

func _ready():
	camera = get_tree().get_first_node_in_group("camera")

	var r: Size
	match randi() % 11:
		0,1,2,3: r = Size.EXTRA_SMALL
		4,5,6: r = Size.SMALL
		7,8: r = Size.MEDIUM
		9: r = Size.LARGE
		10: r = Size.EXTRA_LARGE
		
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
	
	# set initial size
	var scale_factor = start_radius / radius
	%CollisionShape2D.shape.radius = start_radius
	%Sprite2D.scale = Vector2(scale_factor, scale_factor)


func _process(delta):
	var r = %CollisionShape2D.shape.radius
	
	if melting:
		if r > 0.2:
			var new_radius = max(0.1, r - melt_speed * delta)
			var scale_factor = abs(new_radius / radius)
			%CollisionShape2D.shape.radius = new_radius
			%Sprite2D.scale = Vector2(scale_factor, scale_factor)
		else:
			queue_free()
			return

	# grow until target radius is reached
	elif (r != radius):
		var new_radius = clamp(r + grow_speed * delta, start_radius, radius)
		var scale_factor = abs(new_radius / radius)
		%CollisionShape2D.shape.radius = new_radius
		%Sprite2D.scale = Vector2(scale_factor, scale_factor)

	# destroy snowball when it goes offscreen
	var left_frame_x = camera.camera_rect.position.x - camera.camera_rect.size.x / 2
	if (global_position.x < left_frame_x - camera.camera_rect.size.x / 2):
		queue_free()
	

func melt():
	melting = true
