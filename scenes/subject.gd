extends Node2D

# Références aux nœuds enfants
@onready var sprite = $Sprite
@onready var cursor_area = $CursorArea
@onready var subject_area = $SubjectArea

# Variables pour la possession
var is_possessed = false
var can_be_possessed = true
var firsttime = true

# Variables pour le calcul de la vitesse du curseur
var previous_mouse_position = Vector2()
var cursor_speed = 0.0
var speed_samples = []
var current_opacity = MIN_OPACITY  # Initialisé à l'opacité maximale
const MAX_SAMPLES = 13

var obstacles_in_contact = []

# Paramètres pour l'opacité
@export var MIN_SPEED : int = 0    # Vitesse minimale
@export var MAX_SPEED : int= 500  # Vitesse maximale pour l'opacité minimale
@export var MIN_OPACITY : float = 0.15  # Opacité maximale (curseur immobile)
@export var MAX_OPACITY : float = 1  # Opacité minimale (curseur rapide)

func _ready():
	# Connecter les signaux du Area2D
	cursor_area.mouse_entered.connect(_on_CursorArea_mouse_entered)
	cursor_area.mouse_exited.connect(_on_CursorArea_mouse_exited)


func _process(delta):
	if is_possessed:
		var current_mouse_position = get_viewport().get_mouse_position()
		var movement_vector = current_mouse_position - global_position
		
		var impact = is_cursor_over_obstacle(current_mouse_position,previous_mouse_position)
		if impact:
			is_possessed = false
			global_position = impact
			#can_be_possessed = false
			reset_opacity()
			return
		
		global_position += movement_vector
		#distance parcourue depuis la dernière frame
		var distance = current_mouse_position.distance_to(previous_mouse_position)
		#vitesse instantanée
		var instant_speed = distance / delta
		
		speed_samples.append(instant_speed)
		if speed_samples.size() > MAX_SAMPLES:
			speed_samples.remove_at(0)  

		cursor_speed = 0.0
		for speed in speed_samples:
			cursor_speed += speed
		cursor_speed /= speed_samples.size()
		opacity_change(delta)
		previous_mouse_position = current_mouse_position

func is_cursor_over_obstacle(cursor_position: Vector2,previous_cursors_position) :
	var space_state = get_world_2d().direct_space_state

	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.hit_from_inside = true
	ray_params.to = cursor_position
	ray_params.from = previous_cursors_position
	ray_params.collision_mask = 2  # Assurez-vous que les obstacles sont sur la couche 2
	ray_params.collide_with_bodies = true
	ray_params.collide_with_areas = false

	
	var collisionray = space_state.intersect_ray(ray_params)

	if collisionray.size() > 0:
		var collider = collisionray.get("collider")
		if collider.is_in_group("Obstacles"):
			return collisionray.get("position")
	
	# Créer les paramètres de la requête
	#var point_params = PhysicsPointQueryParameters2D.new()
	#point_params.position = cursor_position
	#point_params.collide_with_areas = false
	#point_params.collide_with_bodies = true
	#point_params.collision_mask = 2  # Assurez-vous que les obstacles sont sur la couche 2		
	#var collisionpoint = space_state.intersect_point(point_params, 1)
	#if collisionpoint.size() > 0:
	#	var collider = collisionpoint[0]["collider"]
	#	print("il y a collision point")
	#	if collisionray.size() > 0:
	#		print("il y a collision aussi ray")
	#	if collider.is_in_group("Obstacles"):
	#		return previous_cursors_position
		
	return null

func opacity_change(delta):
	# Mappage de la vitesse à l'opacité 
	var clamped_speed = clamp(cursor_speed, MIN_SPEED, MAX_SPEED)
	var t = (clamped_speed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
	var target_opacity = lerp(MIN_OPACITY, MAX_OPACITY, t)

	# Interpolation manuelle de l'opacité
	var interpolation_speed = 7.0  #valeur pour changer la rapidité du lissage
	current_opacity = lerp(current_opacity, target_opacity, interpolation_speed * delta)

	var modulate_color = sprite.modulate
	modulate_color.a = current_opacity
	sprite.modulate = modulate_color

func reset_opacity():
	current_opacity = MIN_OPACITY
	var modulate_color = sprite.modulate
	modulate_color.a = current_opacity
	sprite.modulate = modulate_color


func _on_CursorArea_mouse_entered():
	print("cursor entered")
	if can_be_possessed:
		is_possessed = true
		print(is_possessed)
		if firsttime:
			previous_mouse_position = get_viewport().get_mouse_position()
			firsttime = false
	
func _on_CursorArea_mouse_exited():
	#is_possessed = false
	# Réinitialiser l'opacité du sprite
	var modulate_color = sprite.modulate
	modulate_color.a = MIN_OPACITY
	sprite.modulate = modulate_color
	
func _on_subject_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Obstacles"):
		obstacles_in_contact.append(body)

func _on_subject_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Obstacles"):
		obstacles_in_contact.erase(body)
