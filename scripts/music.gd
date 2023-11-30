extends AudioStreamPlayer


func _on_music_button_button_up():
	if playing:
		stop()
		%MusicButton.text = "Music: Off"
	else:
		play()
		%MusicButton.text = "Music: On"


func _on_sound_button_button_up():
	if %Character.sound_enabled:
		%Character.sound_enabled = false
		%SoundButton.text = "Sound: Off"
	else:
		%Character.sound_enabled = true
		%SoundButton.text = "Sound: On"
		


func _on_sound_button_start_button_up():
	if playing:
		stop()
		%SoundButtonStart.text = "Sound: Off"
		%MusicButton.text = "Music: Off"
		%Character.sound_enabled = false
		%SoundButton.text = "Sound: Off"
	else:
		play()
		%SoundButtonStart.text = "Sound: On"
		%MusicButton.text = "Music: On"
		%Character.sound_enabled = true
		%SoundButton.text = "Sound: On"

