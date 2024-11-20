extends Area2D

signal animation_finie

var assigned_key = ""
var assigned_note = []
var souris_dessus = false


func _ready():
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	$CollisionShape2D.shape.radius = GameVariable.rayon
	$CollisionShape2D/Sprite2D.scale *= GameVariable.rayon/50

func set_c_position(pos):
	position = pos

func set_key(key):
	if key is String:
		$KeyLabel.text = key
	else:
		if key == 1:
			$KeyLabel.text = "LC"
		if key == 2:
			$KeyLabel.text = "RC"
	scale = Vector2(1, 1)
	$KeyLabel.modulate.a = 1.0
	assigned_key = key
	

func mouse_is_on():
	souris_dessus = true

func _on_mouse_entered():
	souris_dessus = true

func _on_mouse_exited():
	souris_dessus = false

func est_souris_dessus():
	return souris_dessus
						
func current_key():
	return assigned_key
	
func set_note(note):
	assigned_note = note

func consume_circle():
	$CollisionShape2D.disabled
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.16, 1.16), 0.08)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.48)
	tween.tween_property($KeyLabel, "modulate:a", 0, 0.08)
	tween.tween_callback(animation_terminee)

func animation_terminee():
	emit_signal("animation_finie")
	queue_free()
