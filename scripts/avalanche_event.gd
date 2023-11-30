extends Node2D

var snowball_scene = load("res://snowball.tscn")
var spawners = []


func _ready():
	spawners = get_children().filter(func(x): return x.is_in_group("spawn_marker"))


func start():
	$AvalancheEmitTimer.start()
	$AvalancheDurationTimer.start()


func _on_avalanche_emit_timer_timeout():
	for s in spawners:
		var wait_time = randf_range(0, .5)
		await get_tree().create_timer(wait_time).timeout
		var instance = snowball_scene.instantiate()
		instance.position = s.position
		instance.modulate = Color('f2cee3')
		instance.avalanche = true
		add_child(instance)


func _on_avalanche_duration_timer_timeout():
	$AvalancheEmitTimer.stop()
