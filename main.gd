extends Node2D
var score = 0
var temps_restant = 30  # Durée du jeu en secondes
var cercle_actuel = null
var touches_possibles = []
var jeu_en_cours = true
var start_time = 0.0
var errors = 0
var reaction_times = []
var totalpress = 0
var rightpress = 0
var duree_tot

func _ready():
	# Initialisation des touches possibles (A à Z)
	for i in range(26):
		touches_possibles.append('A')
		touches_possibles.append('Z')
		touches_possibles.append('E')
		touches_possibles.append('R')
		touches_possibles.append('Q')
		touches_possibles.append('D')
		touches_possibles.append('F')
		touches_possibles.append('S')
		
	# Démarrage du jeu
	demarrer_jeu(30)

func demarrer_jeu(duration):
	rightpress = 0
	totalpress = 0
	score = 0
	duree_tot = duration
	temps_restant = duree_tot
	errors = 0
	reaction_times = []
	jeu_en_cours = true
	mettre_a_jour_score()
	mettre_a_jour_temps()
	generer_nouveau_cercle()
	# Démarrer un timer pour le décompte du temps
	var timer = $Timer
	timer.wait_time = 0.1
	timer.timeout.connect(_on_Timer_timeout)
	add_child(timer)
	timer.start()


func mettre_a_jour_score():
	score = rightpress * (float(rightpress) / max(totalpress,1))
	get_node("LabelScore").text = "Score: %.2f" % score

func mettre_a_jour_temps():
	get_node("LabelTime").text = "Temps: %.1f" % temps_restant

func generer_nouveau_cercle():
	
	var cercle_scene = load("res://Circle.tscn")
	cercle_actuel = cercle_scene.instantiate()
	add_child(cercle_actuel)
	cercle_actuel.new_circle(touches_possibles)
	start_time = Time.get_ticks_msec()

func _on_Timer_timeout():
	if jeu_en_cours:
		temps_restant -= 0.1
		mettre_a_jour_temps()
		if temps_restant <= 0:
			jeu_en_cours = false
			fin_du_jeu()

func _input(event):
	if jeu_en_cours and event is InputEventKey and event.pressed and not event.echo:
		totalpress += 1
		var touche_presse = OS.get_keycode_string(event.keycode)
		# Conversion en majuscule pour correspondre aux touches assignées
		touche_presse = touche_presse.to_upper()
		if cercle_actuel :
			if cercle_actuel.est_souris_dessus():
				if touche_presse == cercle_actuel.obtenir_touche_assignée():
					rightpress += 1
					var reaction_time = Time.get_ticks_msec() - start_time
					reaction_times.append(reaction_time)
					cercle_actuel.jouer_animation()
					generer_nouveau_cercle()
				else:
					errors += 1
			else:
				errors += 1
		mettre_a_jour_score()

func fin_du_jeu():
	if cercle_actuel:
		cercle_actuel.queue_free()
	
	var label_fin = Label.new()
	var replay_button = Button.new()
	var spintime = SpinBox.new()
	var average_reaction_time = 0.0
	label_fin.name = "LabelFin"
	for time in reaction_times:
		average_reaction_time += time
	average_reaction_time /= reaction_times.size()
	
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

	add_child(spintime)
	add_child(label_fin)
	add_child(replay_button)

func _on_ReplayButton_pressed():
	var duration = get_node("SpinTime").value
	get_node("LabelFin").queue_free()
	get_node("ReplayButton").queue_free()
	get_node("SpinTime").queue_free()
	demarrer_jeu(duration)
