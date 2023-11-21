extends Node2D

var square_scene: PackedScene = load("res://snowball.tscn")
var duration: float
var emit_speed: float
var can_emit = false

@onready var marker = $Marker2D
@onready var camera: Camera2D



func _ready():
	camera = get_tree().get_first_node_in_group("camera")

	duration = randi_range(.2, .5)
	emit_speed = randi_range(.3, 1)
	
	$EmitTimer.wait_time = emit_speed
	$EmitTimer.timeout.connect(_spawn)
	
	$EndTimer.wait_time = duration * camera.camera_rect.position.y / 100
	$EndTimer.timeout.connect(_on_end_timer_timeout)


func _process(delta):
	# if the right side of the viewport is farther right 
	# than this spawner's position, start emit
	if camera.camera_rect and camera.camera_size:
		var right_frame = camera.camera_rect.position.x + camera.camera_size.x
		if (right_frame < position.x):
			can_emit = true
		

func _spawn():
	if can_emit:
		var instance = square_scene.instantiate()
		add_child(instance)
		instance.global_position = marker.global_position


func _on_end_timer_timeout():
	can_emit = false


func _on_player_enter():
	can_emit = true
	
	
