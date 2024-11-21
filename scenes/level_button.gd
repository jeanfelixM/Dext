extends TextureButton

var leveln : Level
func _ready() -> void:
	pass # Replace with function body.


func create_level_button(lpath : String):
	var levelscene = load("res://scenes/level.tscn")
	leveln = levelscene.instantiate()
	GameVariable.add_child(leveln)
	
	leveln.set_fn(lpath)
	leveln.load_level()
	leveln.load_level_score()
	$VBoxContainer/LabelName.text = "Nom: " + leveln.level_name  
	$VBoxContainer/LabelDuree.text =" durée: " + str(leveln.level_duration) 
	$VBoxContainer/LabelTaille.text = " Taille des cercles: " + str(leveln.level_rayon)
	$VBoxContainer/LabelDifficulte.text = ("Difficulté: %.2f"%leveln.difficulty)
	$VBoxContainer/LabelScore.text = ("Highest score: %.2f"%leveln.hs)
	

func _on_pressed() -> void:
	leveln.push_level()
	get_tree().change_scene_to_file("res://scenes/gamescene.tscn")
