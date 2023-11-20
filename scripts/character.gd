extends CharacterBody2D

signal player_death

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export var max_velocity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
@export var jump_threshold = 0.1

@onready var player_width: float
@onready var camera: Camera2D = %Camera2D
@onready var animator: AnimationPlayer = %AnimationPlayer
@onready var anim_tree: AnimationTree = %AnimationTree

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


func _update_animation():
	var state_machine = anim_tree["parameters/playback"]
	var x_dir = Input.get_axis("left", "right")
	
	if not on_ground:
		if (velocity.y < -jump_threshold):
			state_machine.travel("jump_loop")
		elif (velocity.y > jump_threshold): 
			state_machine.travel("fall_loop")
		else:
			state_machine.travel("idle")
	else:
		if x_dir != 0:
			anim_tree.set("parameters/walk_right/blend_position", x_dir)
			state_machine.travel("walk_right")
		else:
			state_machine.travel("idle")
	
	if (velocity.x < 0):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false


func _detect_death(delta):
	# detect player death by off camera position
	if not is_onscreen:
		time_elapsed_offscreen += delta
		
	if time_elapsed_offscreen >= time_offscreen_til_death:
		print("death by offscreen")
		player_death.emit()
	
	# detect player death by crushing
	if (bodies_on_head.size() > 0 and on_ground):
		print("death by crushing")
		time_elapsed_crushed += delta
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, .1)
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, .1)
	else: 
		time_elapsed_crushed = 0
		$Sprite2D.self_modulate = 0xffffffff
		
	if time_elapsed_crushed > time_crushed_til_death:
		player_death.emit()


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
	
	move_and_slide()
	_update_animation()
	_detect_death(delta)	


func _on_ground_detector_body_entered(body):
	on_ground = true
	jumps_since_ground = 0
	#player_state = State.IDLE


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
	# die on supersize touch to head
	#if ("supersize" in body.get_groups()):
	#	player_death.emit()


func _on_head_detector_body_exited(body):
	bodies_on_head.erase(body)
	

