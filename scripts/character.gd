extends Node2D

@export var speed = 5000
@export var jump_speed = 250
@export var max_x_velocity = 1000

@onready var character = %Character

func _physics_process(delta):
	# cast ray down to see if we're standing on anything
	var space_state = get_world_2d().direct_space_state
	var start_pos = %Character.global_position
	var end_pos = Vector2(start_pos.x, %Character/CollisionShape2D.shape.height + start_pos.y)
	var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos)
	var ground_collision = space_state.intersect_ray(query)

	# jump if standing we're on something
	if (ground_collision and Input.get_action_strength("jump")):
		character.apply_impulse(Vector2(0.0, -jump_speed))
		#character.apply_central_force(Vector2(0, -jump_speed))

	# move sideways direction
	var x_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	var x_vel = min(max_x_velocity, speed)
	# moving sidways in air is slower
	#if ground_collisions:
	#	x_vel = speed * .5
	character.apply_central_force(Vector2(x_dir * x_vel, 0.0))
