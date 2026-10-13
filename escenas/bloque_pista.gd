extends Node3D

# Referencias a las escenas de los obstáculos pre-creados
@export var pared_verde_scene: PackedScene
@export var piramide_scene: PackedScene

@onready var spawn_points: Array[Node3D] = [$PuntoIzq, $PuntoCentro, $PuntoDr]

func _ready() -> void:
	#Pinta el obstáculo en un punto aleatorio
	spawn_random_obstacle()

func spawn_random_obstacle() -> void:
	# Elección aleatoria de carril (0: Izquierda, 1: Centro, 2: Derecha)
	var random_index = randi() % spawn_points.size()
	var selected_point = spawn_points[random_index]

	# Elección aleatoria de obstáculo
	var chance = randf()
	var new_obstacle: Node3D = null

	if chance < 0.4 and pared_verde_scene:
		new_obstacle = pared_verde_scene.instantiate()
	elif chance < 0.8 and piramide_scene:
		new_obstacle = piramide_scene.instantiate()

	if new_obstacle:
		selected_point.add_child(new_obstacle)
