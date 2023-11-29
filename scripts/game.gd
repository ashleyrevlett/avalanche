extends Node2D


@onready var camera = %Camera2D
@onready var score_label = %ScoreLabel

var altitude: float
var high_score: int

enum State {TITLE, GAMEPLAY, PAUSE, GAMEOVER}
var state: State

# Called when the node enters the scene tree for the first time.
func _ready():	
	state = State.TITLE
	%StartButton.grab_focus()
	%StartButton.button_up.connect(_start_game)
	
	%GameOverRestartButton.button_up.connect(_restart_game)
	%QuitButton.button_up.connect(_restart_game)
	%ResumeButton.button_up.connect(_unpause_game)
	%Character.player_death.connect(_on_game_over)
	
	load_high_score()
	if high_score > 0:
		%HighScoreLabel.text = "HIGH SCORE: %sm" % high_score
	else:
		%HighScoreLabel.hide()

	get_tree().paused = true


func _start_game():
	state = State.GAMEPLAY
	get_tree().paused = false
	%GameStartUI.hide()
	%ScoreUI.show()


func _pause_game():
	state = State.PAUSE
	get_tree().paused = true
	%PauseUI.show()
	%ResumeButton.grab_focus()
	
	
func _unpause_game():
	state = State.GAMEPLAY
	get_tree().paused = false
	%PauseUI.hide()


func _on_game_over():
	state = State.GAMEOVER
	%GameOverLabel.text = "Final Altitude: %sm" % floor(altitude)
	
	if altitude >= high_score:
		%GameOverLabel.text = "NEW HIGH SCORE!\n" + %GameOverLabel.text
		save_high_score(altitude)

	%GameOverUI.show()
	%GameOverRestartButton.grab_focus()
	get_tree().paused = true
	

func _restart_game():
	state = State.TITLE
	var _reload = get_tree().reload_current_scene()


func _process(delta):
	if state == State.GAMEPLAY:
		altitude = max(0, camera.altitude / 20 * -1)
		score_label.text = "Altitude: %sm" % floor(altitude)
		
		if (Input.is_action_just_pressed("pause")):
			_pause_game()


func save_high_score(score):
	if score > high_score:
		var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		save_file.store_line(str(score))
		save_file.close()
		high_score = score
	

func load_high_score():
	if not FileAccess.file_exists("user://savegame.save"):
		high_score = 0
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	high_score = int(save_file.get_line())
	save_file.close()

