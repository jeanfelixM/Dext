extends CanvasLayer

var adding = false
# Called when the node enters the scene tree for the first time.
func _ready():
	populate_item_list()


func populate_item_list():
	$KeysMenu/ItemList.clear()
	for key in GameVariable.key_list:
		print(key)
		if not key is String:
			if key == 1:
				$KeysMenu/ItemList.add_item("L-Click")
			if key == 2:
				$KeysMenu/ItemList.add_item("R-Click")
		else:
			$KeysMenu/ItemList.add_item(str(key))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_delete_button_pressed():
	var idx = $KeysMenu/ItemList.get_selected_items()
	if idx:
		GameVariable.key_listremove_at(idx[0])
		$KeysMenu/ItemList.remove_item(idx[0])
	

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if adding:
			adding = false
			$"KeysMenu/AddingMenu".visible = false
			update_keys_list(event)
	elif event is InputEventMouseButton and event.pressed :
		if adding:
			adding = false
			$"KeysMenu/AddingMenu".visible = false
			update_clicks_list(event.button_index)

func update_keys_list(event):
	var touche_presse = OS.get_keycode_string(event.keycode)
	if GameVariable.key_list.find(touche_presse) == -1:
		GameVariable.key_listappend(touche_presse)
		$KeysMenu/ItemList.add_item(touche_presse)

func update_clicks_list(idx):
	var str = ""
	if idx == 1:
		str = "L-Click"
	if idx == 2:
		str = "R-Click"
	if GameVariable.key_list.find(str) == -1:
		GameVariable.key_listappend(idx)
		$KeysMenu/ItemList.add_item(str)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/param_layer.tscn")


func _on_add_button_pressed():
	adding = true
	$"KeysMenu/AddingMenu".visible = true
