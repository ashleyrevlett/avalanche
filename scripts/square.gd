extends RigidBody2D

@export var shrink_speed = 6
@export var min_radius = 25.0
@export var max_radius = 125.0
@export var grow_velocity = 60

var max_scale = 10.0;

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
	

func _ready():
	var random_r = randf_range(min_radius, max_radius)
	var r_scale = remap_range(random_r, min_radius, max_radius, .5, 2.25)
	%CollisionShape2D.shape.radius = random_r
	%Sprite2D.scale = Vector2(r_scale, r_scale)
	

func _process(delta):
	# if rolling down, grow snowball
	if (abs(linear_velocity.x) > grow_velocity):
		grow(delta)

	# if off screen, remove it
	if (position.y > 2500):
		queue_free()


func grow(delta):
	pass
	"""
	if %CollisionShape2D.scale.x <= max_scale:
		var new_scale =  %CollisionShape2D.scale * (delta * grow_velocity)
		%CollisionShape2D.scale = new_scale
		%Sprite2D.scale = new_scale
	"""
	"""
	if %CollisionShape2D.shape.radius <= max_radius:
		# var new_radius = lerp(min_radius, max_radius, %CollisionShape2D.shape.radius + grow_velocity * delta)
		# %CollisionShape2D.shape.radius = new_radius
		%CollisionShape2D.shape.radius += grow_velocity * delta
		# %CollisionShape2D.shape.radius += grow_velocity * delta * abs(linear_velocity.x) / 100
	"""
	
func shrink(delta):
	%CollisionShape2D.shape.radius -= shrink_speed * delta
	if %CollisionShape2D.shape.radius <= 0:
		queue_free()
