extends Node2D

# Référence au sprite animé du curseur
@onready var animated_sprite = $AnimatedSprite

func _ready():
	# Cache le curseur système
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta):
	# Met à jour la position du curseur pour suivre la souris
	global_position = get_viewport().get_mouse_position()
