extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$ParamMenu/ButtonContainer/HBoxContainer/SpinBox.value = GameVariable.duration
	$ParamMenu/ButtonContainer/HBoxContainer/OptionButton.select(GameVariable.mode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





func _on_keys_button_pressed():
	get_tree().change_scene_to_file("res://scenes/keys_layer.tscn")


func _on_resume_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_spin_box_value_changed(value):
	GameVariable.durationchange(value)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_option_button_item_selected(index):
	GameVariable.modechange(index)


func _on_option_button_item_focused(index):
	GameVariable.modechange(index)
