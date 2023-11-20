extends RigidBody2D

@export var grow_velocity = 60
@export var min_radius = 10.0
@export var max_radius = 100.0
@export var min_mass = 0.1
@export var max_mass = 1.0


var supersize: bool
var radius: float
var target_radius: float


func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
	

func _ready():
	# 50px is scale=1 for sprite
	supersize = true if randf() < .05 else false
	
	if (supersize):
		target_radius = max_radius * 2
		#%Sprite2D.self_modulate = Color("ff0000")

	else:
		target_radius = randf_range(min_radius, max_radius)
	
	radius = 10.0 # starting size
	
	_update_display()


func _update_display():
	%CollisionShape2D.shape.radius = radius
	var r_scale = remap_range(radius, min_radius, max_radius, .1, 2)
	%Sprite2D.scale = Vector2(r_scale, r_scale)


func _process(delta):
	# if rolling down, grow snowball
	#if (abs(linear_velocity.x) > grow_velocity):
	grow(delta)

	# turn to color, make dangerous		
	if (radius > max_radius and "supersize" not in get_groups()):
		add_to_group("supersize")

	# if off screen, remove it
	#if (position.y > 2500):
	#	queue_free()
		
	


func grow(delta):
	if radius != target_radius:
		radius = min(target_radius, radius + (grow_velocity * delta))
		mass = radius / max_radius
		_update_display()
	
