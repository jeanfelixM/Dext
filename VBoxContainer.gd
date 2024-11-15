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
	var vbox = $VBoxContainer  # Assurez-vous que le chemin est correct
	for score_entry in scores:
		var score_label = Label.new()
		score_label.text = "Score: %.2f" % [score_entry["score"]]
		vbox.add_child(score_label)

func _on_BackButton_pressed():
	# Retourner au menu principal
	get_tree().change_scene("res://MainMenu.tscn")
