extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var levels_folder = "res://levels"
	var dir = DirAccess.open(levels_folder)
	var full_path = ""
	if dir:
		dir.list_dir_begin() # Commence la liste des fichiers
		var file_name = dir.get_next() 
		while file_name != "":
			if not dir.current_is_dir(): # Vérifie si ce n'est pas un dossier
				if file_name.ends_with(".json"):
					print("Fichier trouvé :", file_name)
					full_path = levels_folder + "/" + file_name
					var lbscene = load("res://scenes/level_button.tscn")
					var lb = lbscene.instantiate()
					lb.create_level_button(full_path)
					$ScrollContainer/VBoxContainer.add_child(lb)
					
			file_name = dir.get_next() # Passe au fichier suivant
		dir.list_dir_end() # Termine la liste des fichiers
	else:
		print("Impossible d'ouvrir le dossier :", levels_folder)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
