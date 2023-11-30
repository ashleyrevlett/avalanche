extends CharacterBody2D

signal player_death

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export var max_velocity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
@export var jump_threshold = 0.1
@export var is_at_left_edge = false

@onready var player_width: float
@onready var camera: Camera2D = %Camera2D
@onready var animator: AnimationPlayer = %AnimationPlayer
@onready var anim_tree: AnimationTree = %AnimationTree


var on_ground = true
var grounds_under_player = []
var jumps_since_ground = 0

var time_elapsed_offscreen = 0
var is_onscreen = true
var time_offscreen_til_death = 1 # sec

var bodies_on_head = []
var time_elapsed_crushed = 0
var time_crushed_til_death = .8 # sec


func _ready():
	player_width = %CollisionShape2D.shape.get_rect().size.x
	if Constants.DEBUG:
		%PlayerPos.show()
	else:
		%PlayerPos.hide()


func _update_animation():
	var state_machine = anim_tree["parameters/playback"]
	var x_dir = Input.get_axis("left", "right")
	
	if not on_ground:
		%SnowParticles.emitting = false
		#print(on_ground, " ", velocity.y)
		if (velocity.y < -jump_threshold):
			state_machine.travel("jump_loop")
		elif (velocity.y > jump_threshold * 2): 
			state_machine.travel("fall_loop")
		else:
			state_machine.travel("idle")
		
	else:
		if x_dir != 0:
			anim_tree.set("parameters/walk_right/blend_position", x_dir)
			state_machine.travel("walk_right")
			%SnowParticles.emitting = true
		else:
			state_machine.travel("idle")
			%SnowParticles.emitting = false
	
	if (velocity.x < 0):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false


func _detect_death(delta):
	# detect player death by off camera position
	if not is_onscreen:
		time_elapsed_offscreen += delta
		
	if time_elapsed_offscreen >= time_offscreen_til_death:
		#print("death by offscreen")
		player_death.emit()
	
	# detect player death by crushing
	if (bodies_on_head.size() > 0 and on_ground):
		#print("death by crushing")
		
		if not %DamageParticles.emitting:
			%DamageParticles.emitting = true

		time_elapsed_crushed += delta
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, .1)
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, .1)
		if not %GoatAudio.playing:
			%GoatAudio.play()
	else: 
		time_elapsed_crushed = 0
		$Sprite2D.self_modulate = 0xffffffff
		%GoatAudio.stop()
		if %DamageParticles.emitting:
			%DamageParticles.emitting = false
		
	if time_elapsed_crushed > time_crushed_til_death:
		player_death.emit()



func _physics_process(delta):
	# player movement
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	# don't intentionally move beyond left edge of frame
	is_at_left_edge = global_position.x - (player_width / 2) <= camera.camera_rect.position.x
	if (is_at_left_edge):
		velocity.x = max(0, velocity.x) # only rightward velocity allowed
	
	# player jump + gravity
	velocity.y += gravity * delta
	#print("jumps_since_ground: ", jumps_since_ground)
	if (jumps_since_ground < 2 or grounds_under_player.size() > 0) and Input.is_action_just_pressed("jump"):
		if jumps_since_ground == 1:
			%EffectParticles.emitting = true
		
		%JumpAudio.play()	
		jumps_since_ground += 1
		velocity.y = jump_speed
		
	velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
	
	# apply physics
	move_and_slide()

	_update_animation()
	_detect_death(delta)	


func _process(delta):
	if Constants.DEBUG:
		%PlayerPos.text = "POS: (%s, %s)" % [int(global_position.x), int(global_position.y)]
		%PlayerPos.text += "\nVEL: (%s, %s)" % [int(velocity.x), int(velocity.y)]
		%PlayerPos.text += "\non_ground: %s" % on_ground
		%PlayerPos.text += "\nFPS: %d" % int(Engine.get_frames_per_second())
		


func _on_ground_detector_body_entered(body):
	grounds_under_player.append(body)
	on_ground = true
	jumps_since_ground = 0
	velocity.y = 0


func _on_ground_detector_body_exited(body):
	grounds_under_player.erase(body)
	if grounds_under_player.size() == 0:
		on_ground = false


func _on_screen_exited():
	is_onscreen = false
	#print("_on_screen_exited, is_onscreen:", is_onscreen)


func _on_screen_entered():
	is_onscreen = true
	time_elapsed_offscreen = 0
	#print("_on_screen_entered, is_onscreen:", is_onscreen)


func _on_head_detector_body_entered(body):
	bodies_on_head.append(body)
	# die on supersize touch to head
	#if ("supersize" in body.get_groups()):
	#	player_death.emit()


func _on_head_detector_body_exited(body):
	bodies_on_head.erase(body)
	

