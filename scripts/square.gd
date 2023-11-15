extends RigidBody2D

@export var shrink_speed = 6
@export var max_radius = 80
@export var grow_velocity = 10

func _process(delta):
	# if rolling down, grow snowball
	if (abs(linear_velocity.x) > grow_velocity):
		grow(delta)
		
	# if off screen, remove it
	if (position.y > 2500):
		queue_free()
		

func grow(delta):
	if %CollisionShape2D.shape.radius <= max_radius:
		%CollisionShape2D.shape.radius += shrink_speed * delta


func shrink(delta):
	%CollisionShape2D.shape.radius -= shrink_speed * delta
	if %CollisionShape2D.shape.radius <= 0:
		queue_free()
