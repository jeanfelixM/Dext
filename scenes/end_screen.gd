extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_stars(stars : int):
	var tween = create_tween()
	print("setting stars " + str(stars))
	if stars >= 1:
		$HBoxContainer/Star1.disabled = false
		tween.tween_property($HBoxContainer/Star1, "scale", Vector2(1.4, 1.4), 0.01)
		tween.tween_property($HBoxContainer/Star1, "scale", Vector2(1, 1), 0.23)
	if stars >= 2:
		$HBoxContainer/Star2.disabled = false
		tween.tween_property($HBoxContainer/Star2, "scale", Vector2(1.4, 1.4), 0.01)
		tween.tween_property($HBoxContainer/Star2, "scale", Vector2(1, 1), 0.23)
	if stars == 3:
		$HBoxContainer/Star3.disabled = false
		tween.tween_property($HBoxContainer/Star3, "scale", Vector2(1.4, 1.4), 0.01)
		tween.tween_property($HBoxContainer/Star3, "scale", Vector2(1, 1), 0.23)
		return

func clear_stars():
	$HBoxContainer/Star1.disabled = true
	$HBoxContainer/Star2.disabled = true
	$HBoxContainer/Star3.disabled = true
	$HBoxContainer/Star1.scale = Vector2(1, 1)
	$HBoxContainer/Star2.scale = Vector2(1, 1)
	$HBoxContainer/Star3.scale = Vector2(1, 1)
