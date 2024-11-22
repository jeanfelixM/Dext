class_name GameScene
extends Node2D

signal took_damage
signal colided

var score = 0
var temps_restant = 30  # Durée du jeu en secondes
var touches_possibles = []
var jeu_en_cours = true
var start_time = 0.0
var errors = 0
var reaction_times = []
var totalpress = 0
var rightpress = 0
var health = 3
var circle_count = 0
var duree_tot
var stars = 0
var win = false
var reaction_time = 100
var pos
var scores = []
var cercles= []
var positions = [Vector2(0,0)]
var gm: GameMode = null

func _ready():
	touches_possibles = GameVariable.key_list
	charger_scores()
	demarrer_jeu(GameVariable.duration)

func get_gamemode():
	print("gm est" + str(GameVariable.mode))
	var gmd
	gmd = load("res://game_mode_%d.tscn"%GameVariable.mode)
	gmd = gmd.instantiate()
	add_child(gmd)
	return gmd

func demarrer_jeu(duration):
	$BackgroundMusic.play()
	zerod_vars()
	mettre_a_jour_score()
	gm = get_gamemode()
	gm.lost.connect(_on_lost)
	gm.won.connect(_on_win)
	
	if GameVariable.mode == 2 || GameVariable.mode == 3:
		$LabelHealth.visible = true
		$LabelHealth.text = "Vie: 3"
	
	if not GameVariable.mode == 2:
		duree_tot = duration
		temps_restant = duree_tot
		mettre_a_jour_temps()
		# Démarrer un timer pour le décompte du temps
		var timer = $Timer
		timer.wait_time = 0.1
		timer.timeout.connect(_on_Timer_timeout)
		add_child(timer)
		timer.start()
		
	generer_nouveau_cercle()
	circle_count -= 1
	

func zerod_vars():
	start_time = 0.0
	stars = 0
	positions = [Vector2(0,0)]
	circle_count = 0
	win = false
	scores = []
	cercles= []
	health = 3
	rightpress = 0
	totalpress = 0
	score = 0
	errors = 0
	reaction_times = []
	jeu_en_cours = true

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	$fps.text = "FPS: " + str(fps)

func generer_nouveau_cercle():
	
	var cercle_scene = load("res://scenes/Circle.tscn")
	var cercle = cercle_scene.instantiate()
	var prevpos = positions[-1]
	var cposition = get_c_position(circle_count,prevpos.x,prevpos.y)
	var ckey = get_key(circle_count,touches_possibles)
	var cnote = get_note(circle_count)
	var mouse_pos = get_global_mouse_position()
	if pow((mouse_pos.x - cposition.x),2) +  pow((mouse_pos.y - cposition.y),2) <= pow(GameVariable.rayon, 2) :
		cercle.mouse_is_on()
	cercle.set_c_position(cposition)
	cercle.set_key(ckey)
	cercle.set_note(cnote)
	
	add_child(cercle)
	positions.append(cposition)
	cercles.append(cercle)
	
	start_time = Time.get_ticks_msec()
	circle_count += 1

func get_note(count):
	if GameVariable.notes_list.size() > 0:
		return GameVariable.notes_list[count % GameVariable.notes_list.size()]
	else:
		return "C4"

func get_key(count, touches_possibles):
	return gm.get_key(count,touches_possibles)
			
func get_c_position(count,prevx,prevy):
	var viewport_size = get_viewport_rect().size
	var rayon = GameVariable.rayon
	var positionc = gm.get_c_position(count,prevx,prevy, viewport_size.x,viewport_size.y,rayon)
	return positionc

func charger_scores():
	var file = FileAccess.open("user://scores.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		scores = JSON.parse_string(content)
	else:
		scores = []

func mettre_a_jour_score():
	score = rightpress * (float(rightpress) / max(totalpress,1))
	$LabelScore.text = "Score: %.2f" % score

func mettre_a_jour_temps():
	$LabelTime.text = "Temps: %.1f" % temps_restant
	
func mettre_a_jour_vie():
	$LabelHealth.text = "Vie: %d" % health


func _on_Timer_timeout():
	if jeu_en_cours:
		temps_restant -= 0.1
		mettre_a_jour_temps()
		if temps_restant <= 0:
			jeu_en_cours = false
			fin_du_jeu()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("ui_cancel"):
			handle_pause()
			return 	
	var keystroke = (event is InputEventKey and event.pressed)
	var click = (event is InputEventMouseButton and event.pressed)
	if jeu_en_cours  and (keystroke || click):
		play_game(keystroke,click,event)
		mettre_a_jour_score()

func handle_pause():
	if get_tree().paused:
		get_tree().paused = false
		hide_pause_menu()
	else:
		get_tree().paused = true
		show_pause_menu()
		
func play_game(keystroke,click,event):
	print("REACTION")
	
	var right_input
	totalpress += 1
	var usedF = false
	if keystroke:
		var touche_presse = OS.get_keycode_string(event.keycode)
		touche_presse = touche_presse.to_upper()
		right_input = (cercles[-1].current_key() is String) and (str(touche_presse) == str(cercles[-1].current_key()))
		usedF = (cercles[-1].current_key() is String) and (str(touche_presse) == str('F'))
	elif click:
		right_input = (not cercles[-1].current_key() is String) and event.button_index == cercles[-1].current_key()
	if right_input:
		if cercles[-1] :
			if cercles[-1].est_souris_dessus():
				$AudioNotePlayer.jouer_accord(cercles[-1].assigned_note,1.5)
				cercles[-1].consume_circle()
				generer_nouveau_cercle()
				rightpress += 1
				var reaction_time = Time.get_ticks_msec() - start_time
				reaction_times.append(reaction_time)
			else:
				errors += 1
				emit_signal("took_damage")
	else:
		errors += 1
		emit_signal("took_damage")
	
	var condition = false
	if GameVariable.mode == 3:
		condition = circle_count >= GameVariable.notes_list.size() and (not win)
	if GameVariable.mode == 2:
		condition = usedF
	
	var res = gm.handle_gm(condition,health)
	if not win:
		win = res

func calculate_stars():
	var a = GameVariable.level.reaction_time
	if reaction_time <= 0.7*GameVariable.level.reaction_time:
		return 3
	if reaction_time <= 0.9*GameVariable.level.reaction_time:
		return 2
	if reaction_time <= GameVariable.level.reaction_time:
		return 1
	else : 
		return 0

func fin_du_jeu():
	print("fini jeu")
	$BackgroundMusic.stop()
	jeu_en_cours = false
	if cercles[-1]:
		cercles[-1].queue_free()
	
	var average_reaction_time = 0.0
	for time in reaction_times:
		average_reaction_time += time
	average_reaction_time /= reaction_times.size()
	if GameVariable.mode == 2:
		duree_tot = 1
		gm2troll()
	scores.append({"skill" :score/duree_tot ,"score": score, "time": duree_tot,"error" : errors,"user":GameVariable.username})
	scores.sort_custom(_compare_scores)
	if scores.size() > 10:
		scores = scores.slice(0, 10)
	sauvegarder_scores()
	
	if GameVariable.mode == 3:
		reaction_time = duree_tot/circle_count
		stars = calculate_stars()
	
	create_endscreen(score,duree_tot,average_reaction_time,errors)	
	TuturuPlayer.stop_tuturu()
	

func _compare_scores(a, b):
	return b["score"] < a["score"]

func create_endscreen(score,duree_tot,average_reaction_time,errors):
	$EndScreen.set_stars(stars)
	$EndScreen.visible = true
	$EndScreen/SpinTime.value = GameVariable.duration
	if GameVariable.mode == 3:
		$EndScreen/SpinTime.editable = false
	if GameVariable.mode == 3:
		$EndScreen/HBoxContainer.visible = true
	$EndScreen/LabelFin.text = "Temps écoulé !\nNiveau de skill : %.2f \nScore final : %.2f\nTemps de réaction moyen : %.f ms\nNombre d'erreurs : %d" % [score/duree_tot,score, average_reaction_time, errors]
	$EndScreen/ReplayButton.pressed.connect(_on_ReplayButton_pressed)
	

func gm2troll():
	$EndMusic.play()
	for i in range(5):
		var mouse_pos = get_local_mouse_position()
		var tween = create_tween()
		$MissingPing.position = mouse_pos
		$MissingPing.visible = true
		tween.tween_property($MissingPing, "scale", Vector2(1.1, 1.1), 0.08)
		tween.tween_property($MissingPing, "scale", Vector2(0.2, 0.2), 0.08)
		await get_tree().create_timer(0.25).timeout

func sauvegarder_scores():
	var file
	if GameVariable.level_id > -1:
		file = FileAccess.open("user://sc_lvl_"+str(GameVariable.level_id) +".json", FileAccess.ModeFlags.WRITE)
	else:
		file = FileAccess.open("user://scores.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(scores)
		file.store_string(content)
		file.close()

func _on_ReplayButton_pressed():
	var duration
	if GameVariable.mode == 3:
		duration = GameVariable.duration
	else:
		duration = $EndScreen/SpinTime.value
	$EndScreen/HBoxContainer.visible = false
	$EndScreen.clear_stars()
	$EndScreen.visible = false
	demarrer_jeu(duration)

func show_pause_menu():
	TuturuPlayer.stop_tuturu()
	$PauseMenuLayer/PauseMenu.visible = true

func hide_pause_menu():
	$PauseMenuLayer/PauseMenu.visible = false

func _on_resume_button_pressed():
	get_tree().paused = false
	hide_pause_menu()

func _on_settings_button_pressed():
	# Code pour les paramètres
	pass

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()


func _on_took_damage() -> void:
	if GameVariable.mode == 3 || GameVariable.mode == 2:
		health -=1
		mettre_a_jour_vie()


func _on_lost() -> void:
	fin_du_jeu()
	
func _on_win() -> void:
	pass


func _on_colided() -> void:
	pass # Replace with function body.
