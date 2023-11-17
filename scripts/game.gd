extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	%GameOverUI.hide()
	%GameOverUI.process_mode = Node.PROCESS_MODE_ALWAYS
	%RestartButton.button_up.connect(_restart_game)
	%Character.player_death.connect(_on_game_over)
	get_tree().paused = false
	

func _on_game_over():
	print("Game over!")
	%GameOverUI.show()
	get_tree().paused = true
	

func _restart_game():
	var _reload = get_tree().reload_current_scene()
