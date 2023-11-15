extends Node2D

@export var square_scene: PackedScene

@onready var timer = $Timer
@onready var marker = $Marker2D

func _ready():
	timer.timeout.connect(_spawn)

func _spawn():
	var instance = square_scene.instantiate()
	instance.global_position = marker.global_position
	add_child(instance)
