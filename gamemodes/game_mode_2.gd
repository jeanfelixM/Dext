class_name GameMode2
extends GameMode


func handle_gm(condition: bool,health)-> bool:
	if condition:
		$FlashSound.play()
		var tween = create_tween()
		var mouse_pos = get_local_mouse_position()
		$FlashTexture.position = mouse_pos
		$FlashTexture.visible = true
		tween.tween_property($FlashTexture, "scale", Vector2(1.1, 1.1), 0.08)
		tween.tween_property($FlashTexture, "scale", Vector2(0, 0), 0.08)
	if health <= 0:
		emit_signal("lost")
	return false
