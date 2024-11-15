extends Node2D

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

var pos
var scores = []
var cercles= []
var positions = [Vector2(0,0)]


func generer_nouveau_cercle():
	var cercle_scene = load("res://Circle.tscn")
	var cercle = cercle_scene.instantiate()
	var prevpos = positions[-1]
	var cposition = get_c_position(circle_count,prevpos.x,prevpos.y)
	var ckey = get_key(circle_count,touches_possibles)
	var mouse_pos = get_global_mouse_position()
	if pow((mouse_pos.x - cposition.x),2) +  pow((mouse_pos.y - cposition.y),2) <= pow(GameVariable.rayon, 2) :
		cercle.mouse_is_on()
	cercle.set_c_position(cposition)
	cercle.set_key(ckey)
	
	add_child(cercle)
	positions.append(cposition)
	cercles.append(cercle)
	
	start_time = Time.get_ticks_msec()

func get_key(count, touches_possibles):
	var key
	if GameVariable.mode == 0 || GameVariable.mode == 2:
		print("simple")
		return touches_possibles[randi() % touches_possibles.size()]
	elif GameVariable.mode == 1:
		print("alternate")
		if count%3 == 0:
			key = touches_possibles[randi() % touches_possibles.size()]
		elif count%3 == 1:
			key = 'Q'
		elif count%3 == 2:
			key = 1
		print(count%3)
		return key
			
func get_c_position(count,prevx,prevy):
	var positionc
	var viewport_size = get_viewport_rect().size
	var rayon = GameVariable.rayon
	if GameVariable.mode == 0 || GameVariable.mode == 2:
		var position_x = randf_range(rayon, viewport_size.x - rayon)
		var position_y = randf_range(rayon, viewport_size.y - rayon)
		positionc = Vector2(position_x, position_y)
	elif GameVariable.mode == 1:
		if count%3 == 1:
			positionc = Vector2(prevx,prevy)
		else:
			var position_x = randf_range(rayon, viewport_size.x - rayon)
			var position_y = randf_range(rayon, viewport_size.y - rayon)
			positionc = Vector2(position_x, position_y)
	return positionc

func charger_scores():
	var file = FileAccess.open("user://scores.json", FileAccess.ModeFlags.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		scores = JSON.parse_string(content)
	else:
		# Si le fichier n'existe pas, initialiser une liste vide
		scores = []


func _ready():
	# Initialisation des touches possibles (A à Z)
	
	touches_possibles = GameVariable.key_list
	$FlashTexture.visible = false
	$MissingPing.visible = false
	# Démarrage du jeu
	charger_scores()
	demarrer_jeu(GameVariable.duration)

func demarrer_jeu(duration):
	$BackgroundMusic.play()
	rightpress = 0
	totalpress = 0
	score = 0
	errors = 0
	reaction_times = []
	jeu_en_cours = true
	mettre_a_jour_score()
	if GameVariable.mode == 0 || GameVariable.mode == 1:
		duree_tot = duration
		temps_restant = duree_tot
		mettre_a_jour_temps()
		# Démarrer un timer pour le décompte du temps
		var timer = $Timer
		timer.wait_time = 0.1
		timer.timeout.connect(_on_Timer_timeout)
		add_child(timer)
		timer.start()
	elif GameVariable.mode == 2:
		health = 3
		$LabelTime.text = "Vie: 3"
		
	generer_nouveau_cercle()
	circle_count += 1
	

func mettre_a_jour_score():
	score = rightpress * (float(rightpress) / max(totalpress,1))
	get_node("LabelScore").text = "Score: %.2f" % score

func mettre_a_jour_temps():
	get_node("LabelTime").text = "Temps: %.1f" % temps_restant
	
func mettre_a_jour_vie():
	get_node("LabelTime").text = "Vie: %d" % health



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
	var right_input
	totalpress += 1
	if keystroke:
		var touche_presse = OS.get_keycode_string(event.keycode)
		touche_presse = touche_presse.to_upper()
		right_input = (cercles[-1].current_key() is String) and (str(touche_presse) == str(cercles[-1].current_key()))
		if GameVariable.mode == 2 and (cercles[-1].current_key() is String) and (str(touche_presse) == str('F')):
			$FlashSound.play()
			var tween = create_tween()
			
			var mouse_pos = get_local_mouse_position()
			$FlashTexture.position = mouse_pos
			$FlashTexture.visible = true
			tween.tween_property($FlashTexture, "scale", Vector2(1.1, 1.1), 0.08)
			tween.tween_property($FlashTexture, "scale", Vector2(0, 0), 0.08)
			health -=1
			mettre_a_jour_vie()
			if health <= 0:
				fin_du_jeu()
	elif click:
		right_input = (not cercles[-1].current_key() is String) and event.button_index == cercles[-1].current_key()
	if right_input:
		if cercles[-1] :
			if cercles[-1].est_souris_dessus():
				cercles[-1].jouer_animation()
				generer_nouveau_cercle()
				rightpress += 1
				var reaction_time = Time.get_ticks_msec() - start_time
				reaction_times.append(reaction_time)
				circle_count += 1
			else:
				errors += 1
	else:
		errors += 1

func fin_du_jeu():
	jeu_en_cours = false
	if cercles[-1]:
		cercles[-1].queue_free()
	
	var label_fin = Label.new()
	var replay_button = Button.new()
	var spintime = SpinBox.new()
	var average_reaction_time = 0.0
	label_fin.name = "LabelFin"
	for time in reaction_times:
		average_reaction_time += time
	average_reaction_time /= reaction_times.size()
	if GameVariable.mode == 2:
		duree_tot = 1
	scores.append({"skill" :score/duree_tot ,"score": score, "time": duree_tot,"error" : errors,"user":GameVariable.username})
	scores.sort_custom(_compare_scores)
	if scores.size() > 10:
		scores = scores.slice(0, 10)
	sauvegarder_scores()
	
	label_fin.text = "Temps écoulé !\nNiveau de skill : %.2f \nScore final : %.2f\nTemps de réaction moyen : %.f ms\nNombre d'erreurs : %d" % [score/duree_tot,score, average_reaction_time, errors]
	label_fin.position = get_viewport_rect().size / 2
	
	replay_button.name = "ReplayButton"
	replay_button.text = "Rejouer"
	replay_button.position = label_fin.position + Vector2(10, 150)
	# Connecter le signal
	replay_button.pressed.connect(_on_ReplayButton_pressed)
	
	spintime.min_value = 15
	spintime.max_value = 120
	spintime.value = 30
	spintime.name = "SpinTime"
	spintime.position = replay_button.position + Vector2(0, 40)

	$BackgroundMusic.stop()
	if GameVariable.mode == 2:
		$EndMusic.play()
		for i in range(5):
			var mouse_pos = get_local_mouse_position()
			var tween = create_tween()
			$MissingPing.position = mouse_pos
			$MissingPing.visible = true
			tween.tween_property($MissingPing, "scale", Vector2(1.1, 1.1), 0.08)
			tween.tween_property($MissingPing, "scale", Vector2(0.2, 0.2), 0.08)
			await get_tree().create_timer(0.25).timeout
		
	TuturuPlayer.stop_tuturu()
	add_child(spintime)
	add_child(label_fin)
	add_child(replay_button)

func _compare_scores(a, b):
	return b["score"] < a["score"]

func sauvegarder_scores():
	var file = FileAccess.open("user://scores.json", FileAccess.ModeFlags.WRITE)
	if file:
		var content = JSON.stringify(scores)
		file.store_string(content)
		file.close()

func _on_ReplayButton_pressed():
	var duration = get_node("SpinTime").value
	get_node("LabelFin").queue_free()
	get_node("ReplayButton").queue_free()
	get_node("SpinTime").queue_free()
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
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()


