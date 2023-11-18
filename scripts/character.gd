extends CharacterBody2D

signal player_death

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
@export var max_velocity = 2000

@onready var camera: Camera2D = %Camera2D
@onready var player_width: float

var on_ground = true
var jumps_since_ground = 0
var time_elapsed_offscreen = 0
var is_onscreen = true
var time_offscreen_til_death = 1 # sec

var bodies_on_head = []
var time_elapsed_crushed = 0
var time_crushed_til_death = .2 # sec

func _ready():
	player_width = %CollisionShape2D.shape.get_rect().size.x


func _clamp_position():
	global_position.x = max(camera.camera_rect.position.x + player_width/2, global_position.x)
	global_position.x = min(camera.camera_rect.end.x - player_width/2, global_position.x)


func _physics_process(delta):
	# player movement
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	# player jump + gravity
	velocity.y += gravity * delta
	if jumps_since_ground < 2 and Input.is_action_just_pressed("jump"):
		jumps_since_ground += 1
		velocity.y = jump_speed

	velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
	#print(velocity)

	move_and_slide()
	
	_clamp_position()
	
	# detect player death by off camera position
	if not is_onscreen:
		time_elapsed_offscreen += delta
		# print("time_elapsed_offscreen", time_elapsed_offscreen)
		
	if time_elapsed_offscreen >= time_offscreen_til_death:
		player_death.emit()
	
	# detect player death by crushing
	if (bodies_on_head.size() > 0 and on_ground):
		time_elapsed_crushed += delta
		%AnimationPlayer.play("dying")
	else: 
		time_elapsed_crushed = 0
		%AnimationPlayer.play("RESET")
	
	if time_elapsed_crushed > time_crushed_til_death:
		player_death.emit()
	

func _on_ground_detector_body_entered(body):
	on_ground = true
	jumps_since_ground = 0


func _on_ground_detector_body_exited(body):
	on_ground = false


func _on_screen_exited():
	is_onscreen = false
	print("_on_screen_exited, is_onscreen:", is_onscreen)


func _on_screen_entered():
	is_onscreen = true
	time_elapsed_offscreen = 0
	print("_on_screen_entered, is_onscreen:", is_onscreen)


func _on_head_detector_body_entered(body):
	bodies_on_head.append(body)


func _on_head_detector_body_exited(body):
	bodies_on_head.erase(body)
	

