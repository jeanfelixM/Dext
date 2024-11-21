class_name LevelTrack
extends Resource
var internal_ccount = 0

#0 for random
#1 for pattern
#2 for smart pattern
func get_apparition_mode(ccount : int) -> int:
	return 0
	
func get_pattern_pk(ccount : int): #-> (String,Vector2):
	return ["",Vector2()]
	
func get_smartpattern_pk(ccount : int,seed : int): #-> (String,Vector2):
	return ["",Vector2()]
