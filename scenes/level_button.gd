extends TextureButton


func _ready() -> void:
	pass # Replace with function body.


func create_level_button(lpath : String):
	$Level.set_fn(lpath)
	$Level.load_level()
	$VBoxContainer/LabelName.text = "Nom: " + $Level.level_name  
	$VBoxContainer/LabelDuree.text =" durée: " + str($Level.level_duration) 
	$VBoxContainer/LabelTaille.text = " Taille des cercles: " + str($Level.level_rayon)

func _on_pressed() -> void:
	$Level.push_level()
	get_tree().change_scene_to_file("res://scenes/gamescene.tscn")
