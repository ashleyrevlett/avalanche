extends Sprite2D

var offscreen_y = -100
var melt: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = offscreen_y
	

func appear(duration: float):
	var tween = create_tween()
	var transition_time = duration / 4
	tween.tween_property(self, "position:y", 100, transition_time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	melt = true
	await get_tree().create_timer(duration - transition_time * 2).timeout
	var tween2 = create_tween()
	tween2.tween_property(self, "position:y", offscreen_y, transition_time)
	await tween2.finished
	melt = false

func _process(delta):
	if melt:
		var snowballs = get_tree().get_nodes_in_group("snowball")
		for s in snowballs:
			s.melt()
