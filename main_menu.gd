extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$username.text = GameVariable.username


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	var game_scene = preload("res://scenes/gamescene.tscn").instantiate()
	game_scene.errors = 1
	TuturuPlayer.play_tuturu()
	GameVariable.level_id = -1
	GameVariable.load_duration()
	GameVariable.load_mode()
	GameVariable.load_notes()
	GameVariable.load_keys()
	get_tree().change_scene_to_file("res://scenes/gamescene.tscn")
	
	
	
	


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/param_layer.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")


func _on_line_edit_text_changed(new_text):
	GameVariable.usernamechange(new_text)


func _on_campagne_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_selector.tscn")
