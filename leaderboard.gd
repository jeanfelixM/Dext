extends Control

var scores = []

func _ready():
	charger_scores()
	afficher_scores()

func charger_scores():
	var file = FileAccess.open("user://scores.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		scores = JSON.parse_string(content)
	else:
		scores = []

func afficher_scores():
	var vbox = $VBoxContainer  
	for score_entry in scores:
		var panel = Panel.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.5)  # Fond noir semi-transparent
		panel.add_theme_stylebox_override("background", style)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Pour remplir la largeur
		panel.custom_minimum_size = Vector2(450, 40)

		var score_label = Label.new()
		score_label.text = "User: %s, Skill: %.2f, Score: %.2f, Error: %.f, Time: %.f" % [score_entry["user"],score_entry["skill"], score_entry["score"], score_entry["error"], score_entry["time"]]
		score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		panel.add_child(score_label)
		vbox.add_child(panel)




func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
