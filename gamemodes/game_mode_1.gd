class_name GameMode1
extends GameMode



func handle_gm(condition: bool,health)-> bool:
	return false

func get_key(count : int, touches_possibles : Array):
	print("alternate")
	var key
	if count%3 == 0:
		key = touches_possibles[randi() % touches_possibles.size()]
	elif count%3 == 1:
		key = 'Q'
	elif count%3 == 2:
		key = 1
	print(count%3)
	return key

func get_c_position(count:int,prevx:float,prevy:float,vpsx:float,vpsy:float,rayon:float):
	var positionc
	if count%3 == 1:
		positionc = Vector2(prevx,prevy)
	else:
		var position_x = randf_range(rayon, vpsx - rayon)
		var position_y = randf_range(rayon, vpsy - rayon)
		positionc = Vector2(position_x, position_y)
	return positionc
