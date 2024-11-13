extends Area2D

signal animation_finie

var touche_assignée = ""
var souris_dessus = false

func _ready():
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)

func new_circle(touches_possibles):
	# Sélection d'une touche aléatoire
	touche_assignée = touches_possibles[randi() % touches_possibles.size()]
	# Mise à jour du label
	$KeyLabel.text = touche_assignée
	# Positionnement aléatoire du cercle
	var viewport_size = get_viewport_rect().size
	var rayon = ($CollisionShape2D.shape as CircleShape2D).radius
	var position_x = randf_range(rayon, viewport_size.x - rayon)
	var position_y = randf_range(rayon, viewport_size.y - rayon)
	position = Vector2(position_x, position_y)
	# Réinitialiser la scale et la transparence au cas où
	scale = Vector2(1, 1)
	$KeyLabel.modulate.a = 1.0

func _on_mouse_entered():
	souris_dessus = true

func _on_mouse_exited():
	souris_dessus = false

func est_souris_dessus():
	return souris_dessus

func obtenir_touche_assignée():
	return touche_assignée

func jouer_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.16, 1.16), 0.08)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.08)
	tween.tween_property($KeyLabel, "modulate:a", 0, 0.08)
	tween.tween_callback(animation_terminee)

func animation_terminee():
	emit_signal("animation_finie")
	queue_free()
