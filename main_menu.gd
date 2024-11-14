extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	var game_scene = preload("res://gamescene.tscn").instantiate()
	game_scene.errors = 1
	get_tree().change_scene_to_file("res://gamescene.tscn")
	
	
	
	


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://param_layer.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://Leaderboard.tscn")
