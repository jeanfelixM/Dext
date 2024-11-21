extends Node

var key_list: Array = ['A','Z','E','R','F','Q']
var duration = 30
var game_mode = 'simple'
var username = "pigeon"
var level_id = -1
var level : Level
var mode = 0
var rayon = 50
var notes_list: Array = []
const tuturu_sound = preload("res://audio/tuturu.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	load_keys()
	load_user()
	load_duration()
	load_mode()
	load_notes()
	var file = FileAccess.open("user://sc_lvl_258874712.json", FileAccess.ModeFlags.READ)
	if file:
		print("on a trouvé score lvl id 258874712")
	else:
		print("pas encore")

func key_listappend(s):
	key_list.append(s)
	save_keys()
	
func key_listremove_at(i):
	key_list.remove_at(i)
	save_keys()

func durationchange(val):
	duration = val
	save_duration()

func load_keys():
	var file = FileAccess.open("user://keys.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		key_list = JSON.parse_string(content)
	else:
		key_list = []
	if key_list.is_empty():
		key_list = ['A','Z','E','R','F','Q']
		
func save_keys():
	var file = FileAccess.open("user://keys.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(key_list)
		file.store_string(content)
		file.close()

func load_notes():
	var file_path = "res://data/notes.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			notes_list = JSON.parse_string(content)
		else:
			print("Impossible d'ouvrir le fichier notes.json")
	else:
		print("Le fichier notes.json n'existe pas")

func load_duration():
	var file = FileAccess.open("user://duration.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		duration = JSON.parse_string(content)
	else:
		duration = 30

func save_duration():
	var file = FileAccess.open("user://duration.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(duration)
		file.store_string(content)
		file.close()

func load_user():
	var file = FileAccess.open("user://user.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		username = JSON.parse_string(content)
	else:
		username = "pigeon"

func save_user():
	var file = FileAccess.open("user://user.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(username)
		file.store_string(content)
		file.close()
		
func load_mode():
	var file = FileAccess.open("user://mode.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		mode = JSON.parse_string(content)
	else:
		mode = 0

func save_mode():
	var file = FileAccess.open("user://mode.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(mode)
		file.store_string(content)
		file.close()

func modechange(idx):
	print("mode")
	print(idx)
	mode = idx
	save_mode()

func usernamechange(str):
	username = str
	save_user()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
