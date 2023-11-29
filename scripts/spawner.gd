extends Node2D

@onready var marker = $Marker2D
@onready var camera: Camera2D

var square_scene: PackedScene = load("res://snowball.tscn")


func _ready():
	camera = get_tree().get_first_node_in_group("camera")
	
	# on each interval, spawn snowball
	# emit speed gets faster the higher you go
	var min_difficulty = 1
	var max_difficulty = 10
	var min_emit_speed = .1
	var max_emit_speed = 1.1
	
	var difficulty_scale = abs(camera.camera_rect.position.y) / 1000
	difficulty_scale = clampf(difficulty_scale, min_difficulty, max_difficulty)
	var emit_speed = remap(difficulty_scale, min_difficulty, max_difficulty, max_emit_speed, min_emit_speed)
	#print("emit_speed:", emit_speed, " // difficulty_scale:", difficulty_scale)
	$EmitTimer.wait_time = emit_speed
	$EmitTimer.timeout.connect(_spawn)
	
	# stop spawning after random duration passes
	# duration is longer the higher you go
	# will also stop automatically when in frame
	var duration = randi_range(.2, .5)
	$EndTimer.wait_time = duration * difficulty_scale
	$EndTimer.timeout.connect(_on_end_timer_timeout)


func _process(delta):
	# start emission once spawner is within a few frames' length of camera
	var right_frame = camera.camera_rect.end 
	var x_limit = right_frame.x + camera.camera_rect.size.x * 3
	
	
	# stop emission once spawner is almost onscreen
	if (global_position.x <= right_frame.x and not $EmitTimer.is_stopped()):
		$EmitTimer.stop()

	elif (global_position.x <= x_limit and global_position.x > right_frame.x and $EmitTimer.is_stopped()):
		$EmitTimer.start()
		$EndTimer.start()
	
	# fyi, accessing global_position of a snowball here breaks physics


func _spawn():
	var instance = square_scene.instantiate()
	add_child(instance)
	instance.position = marker.position


func _on_end_timer_timeout():
	$EmitTimer.stop()
