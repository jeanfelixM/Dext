extends AudioStreamPlayer

const tuturu_sound = preload("res://tuturu.wav")

func _play_music(music: AudioStream, volume = -20.0):
	stream = music
	volume_db = volume
	play()

func play_tuturu():
	_play_music(tuturu_sound)

func stop_tuturu():
	pass
