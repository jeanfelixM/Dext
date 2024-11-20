extends Node

var level_duration = 30;
var level_mode = 0
var level_rayon = 50;
var level_notes_list: Array = []
var level_fn : String = ""
var level_name = ""
var level_id = -1
var level_keys: Array = []


func _ready() -> void:
	pass


func set_fn(fn : String):
	level_fn = fn

func load_level():
	if FileAccess.file_exists(level_fn):
		var file = FileAccess.open(level_fn, FileAccess.ModeFlags.READ)
		if file:
			var content = file.get_as_text()
			var jsoncontent = JSON.parse_string(content)
			level_rayon = jsoncontent["rayon"]
			level_mode = jsoncontent["mode"]
			level_duration = jsoncontent["duration"]
			level_notes_list = jsoncontent["notes"]
			level_name = jsoncontent["name"]
			level_keys = jsoncontent["keys"]
			level_id = jsoncontent["id"]
			file.close()
			print("on a load " + level_fn)
		else:
			print("Impossible d'ouvrir le fichier " + level_fn)
	else:
		print("Le fichier " + level_fn + " n'existe pas")
		
func push_level():
	GameVariable.duration = level_duration
	GameVariable.rayon = level_rayon
	GameVariable.mode = level_mode
	GameVariable.notes_list = level_notes_list
	GameVariable.key_list = level_keys
	GameVariable.level_id = level_id
