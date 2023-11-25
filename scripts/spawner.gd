extends Node2D

@onready var marker = $Marker2D
@onready var camera: Camera2D

var square_scene: PackedScene = load("res://snowball.tscn")


func _ready():
	camera = get_tree().get_first_node_in_group("camera")
	
	# on each interval, spawn snowball
	var emit_speed = randi_range(.3, 1)
	$EmitTimer.wait_time = emit_speed
	$EmitTimer.timeout.connect(_spawn)
	
	# stop spawning after random duration passes
	# duration is longer the higher you go
	
	var difficulty_scale = max(1, camera.camera_rect.position.y / 100)
	var duration = randi_range(.2, .5)
	$EndTimer.wait_time = duration * difficulty_scale
	$EndTimer.timeout.connect(_on_end_timer_timeout)


func _process(delta):
	# if the right side of the viewport is farther right 
	# than this spawner's position, start emit
	if camera.camera_rect:
		var right_frame = camera.camera_rect.end 
		var x_limit = right_frame.x + camera.camera_rect.size.x
		# start emission once spawner is within 1 frame's length of camera
		if (global_position.x <= x_limit and global_position.x > right_frame.x and $EmitTimer.is_stopped()):
			print("triggering spawner")
			$EmitTimer.start()
			$EndTimer.start()
		# stop emission once spawner is onscreen
		if (global_position.x <= right_frame.x and not $EmitTimer.is_stopped()):
			$EmitTimer.stop()


func _spawn():
	var instance = square_scene.instantiate()
	add_child(instance)
	instance.global_position = marker.global_position


func _on_end_timer_timeout():
	$EmitTimer.stop()
