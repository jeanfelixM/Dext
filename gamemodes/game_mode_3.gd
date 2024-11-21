class_name GameMode3
extends GameMode



func handle_gm(condition: bool,health) -> bool:
	print("ON HANDLE DANS GM3")
	var win = false
	if condition :
		$YaySound.play()
		print("gm3 fini !")
		var tween = create_tween()
		$label_win.text = "C'est gagné ! Continue jusqu'à la fin pour augmenter ton score"
		tween.tween_property($label_win, "modulate:a", 0, 5)
		win = true
	if health <= 0:
		print("PERDUUUU")
		emit_signal("lost")
	return win

	
