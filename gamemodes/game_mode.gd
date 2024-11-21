class_name GameMode
extends Node2D

signal lost
signal won

func handle_gm(condition: bool,health)-> bool:
	return false

func get_key(count : int, touches_possibles : Array):
	return touches_possibles[randi() % touches_possibles.size()]

func get_c_position(count:int,prevx:float,prevy:float,vpsx:float,vpsy:float,rayon:float):
	var position_x = randf_range(rayon, vpsx - rayon)
	var position_y = randf_range(rayon, vpsy - rayon)
	var positionc = Vector2(position_x, position_y)
	return positionc
