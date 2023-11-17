extends CharacterBody2D

signal player_death

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25

@onready var camera: Camera2D = %Camera2D
@onready var camera_size: Vector2
@onready var camera_rect: Rect2
@onready var player_width: float

var jumps_since_ground = 0
var time_elapsed_offscreen = 0
var is_onscreen = true
var time_offscreen_til_death = 2 # sec

func _ready():
	player_width = %CollisionShape2D.shape.get_rect().size.x
	print("player_width:", player_width)
	camera_size = get_viewport_rect().size # * camera.zoom
	camera_rect = Rect2(camera.get_screen_center_position() - camera_size / 2, camera_size)
	print(camera_size, camera_rect)


func _clamp_position():
	camera_rect = Rect2(camera.get_screen_center_position() - camera_size / 2, camera_size)
	global_position.x = max(camera_rect.position.x + player_width/2, global_position.x)
	global_position.x = min(camera_rect.end.x - player_width/2, global_position.x)

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

	move_and_slide()
	
	_clamp_position()
	
	# detect player death
	if not is_onscreen:
		time_elapsed_offscreen += delta
		# print("time_elapsed_offscreen", time_elapsed_offscreen)
		
	if time_elapsed_offscreen >= time_offscreen_til_death:
		player_death.emit()
		

func _on_ground_detector_body_entered(body):
	jumps_since_ground = 0


func _on_screen_exited():
	is_onscreen = false
	print("_on_screen_exited, is_onscreen:", is_onscreen)


func _on_screen_entered():
	is_onscreen = true
	time_elapsed_offscreen = 0
	print("_on_screen_entered, is_onscreen:", is_onscreen)
