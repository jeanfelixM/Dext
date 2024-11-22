extends CanvasLayer
# Variable pour le sprite animé du curseur
@onready var animated_sprite = $AnimatedSprite

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Cache le curseur système

func _process(delta):
	# Met à jour la position du curseur pour suivre la souris
	position = get_viewport().get_mouse_position()
