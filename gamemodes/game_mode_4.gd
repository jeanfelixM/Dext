class_name GameMode4
extends GameMode

@export var level_track : LevelTrack

var key = ""
var pos = null

func handle_gm(condition: bool,health)-> bool:
	return false

func get_key(count : int, touches_possibles : Array):
	var apmode = level_track.get_apparition_mode(count)
	if apmode == 0:
		return touches_possibles[randi() % touches_possibles.size()]
	if apmode == 1:
		var nkey
		if key == "":
			var vals = level_track.get_pattern_pk(count)
			nkey = vals[0]
			pos = vals[1]
		else:
			nkey = key
			key = ""
		return key
	if apmode == 2:
		var nkey
		var seed = 0 #a generer aleatoirement nombre entre 1 et 100 disons
		if key == "":
			var vals = level_track.get_smartpattern_pk(count,seed)
			nkey = vals[0]
			pos = vals[1]
		else:
			nkey = key
			key = ""
		return key
		
		
func get_c_position(count:int,prevx:float,prevy:float,vpsx:float,vpsy:float,rayon:float):
	var apmode = level_track.get_apparition_mode(count)
	if apmode == 0:
		var position_x = randf_range(rayon, vpsx - rayon)
		var position_y = randf_range(rayon, vpsy - rayon)
		return Vector2(position_x, position_y)
	if apmode == 1:
		var npos
		if pos == null:
			var vals = level_track.get_pattern_pk(count)
			key = vals[0]
			npos = vals[1]
			return npos
		else:
			npos = pos
			pos = null
			return npos
	if apmode == 2:
		var npos
		var seed = 0 #a generer aleatoirement nombre entre 1 et 100 disons
		if pos == null:
			var vals = level_track.get_smartpattern_pk(count,seed)
			key = vals[0]
			npos = vals[1]
			return npos
		else:
			npos = pos
			pos = null
			return npos
