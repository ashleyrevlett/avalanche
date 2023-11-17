extends Node2D

@export var delay_time: float  = 0
@export var duration: float = 3
@export var emit_speed: float = .3

var square_scene: PackedScene = load("res://snowball.tscn")

@onready var marker = $Marker2D

var can_emit = true


func _ready():
	if delay_time:
		await get_tree().create_timer(delay_time).timeout
		print("Go:", name)
	
	$EmitTimer.wait_time = emit_speed
	$EmitTimer.timeout.connect(_spawn)
	
	$EndTimer.wait_time = duration
	$EndTimer.timeout.connect(_on_end_timer_timeout)

func _spawn():
	if can_emit:
		var instance = square_scene.instantiate()
		add_child(instance)
		instance.global_position = marker.global_position

func _on_end_timer_timeout():
	can_emit = false

