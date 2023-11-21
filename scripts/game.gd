extends Node2D


@onready var camera = %Camera2D
@onready var score_label = %ScoreLabel

var altitude: float

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	%GameStartUI.show()
	%GameOverUI.hide()
	%PauseUI.hide()
	
	%StartButton.button_up.connect(_start_game)
	%GameOverRestartButton.button_up.connect(_restart_game)
	%QuitButton.button_up.connect(_restart_game)
	%ResumeButton.button_up.connect(_unpause_game)
	%Character.player_death.connect(_on_game_over)


func _start_game():
	print("Starting!")
	%GameStartUI.hide()
	get_tree().paused = false


func _pause_game():
	get_tree().paused = true
	%PauseUI.show()
	
	
func _unpause_game():
	get_tree().paused = false
	%PauseUI.hide()


func _on_game_over():
	%GameOverLabel.text = "Final Altitude: %sm" % floor(altitude)
	%GameOverUI.show()
	get_tree().paused = true
	

func _restart_game():
	var _reload = get_tree().reload_current_scene()


func _process(delta):
	altitude = max(0, camera.position.y / 20 * -1)
	score_label.text = "Altitude: %sm" % floor(altitude)
	
	if (Input.is_action_just_pressed("pause")):
		_pause_game()
