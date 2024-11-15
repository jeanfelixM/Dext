extends Area2D

signal animation_finie

var assigned_key = ""
var souris_dessus = false

func _ready():
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)

func new_circle(touches_possibles):
	assigned_key = touches_possibles[randi() % touches_possibles.size()]
	
	if assigned_key is String:
		$KeyLabel.text = assigned_key
	else:
		if assigned_key == 1:
			$KeyLabel.text = "LC"
		if assigned_key == 2:
			$KeyLabel.text = "RC"

	var viewport_size = get_viewport_rect().size
	var rayon = ($CollisionShape2D.shape as CircleShape2D).radius
	var position_x = randf_range(rayon, viewport_size.x - rayon)
	var position_y = randf_range(rayon, viewport_size.y - rayon)
	position = Vector2(position_x, position_y)
	
	scale = Vector2(1, 1)
	$KeyLabel.modulate.a = 1.0

func _on_mouse_entered():
	souris_dessus = true

func _on_mouse_exited():
	souris_dessus = false

func est_souris_dessus():
	return souris_dessus
						
func current_key():
	return assigned_key

func jouer_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.16, 1.16), 0.08)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.08)
	tween.tween_property($KeyLabel, "modulate:a", 0, 0.08)
	tween.tween_callback(animation_terminee)

func animation_terminee():
	emit_signal("animation_finie")
	queue_free()
