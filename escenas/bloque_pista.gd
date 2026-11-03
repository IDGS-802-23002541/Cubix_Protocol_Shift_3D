# Nombre archivo: bloque_pista
# Versión: v1.1
# Descripción: Generación obstáculos aleatorios pista
# Autor: Aideé Vanessa Casillas Tapia

extends Node3D

# Referencias a las escenas de los obstáculos pre-creados
@export var pared_verde_scene: PackedScene
@export var piramide_scene: PackedScene
@export var databit_scene: PackedScene 

@onready var spawn_points: Array[Node3D] = [$PuntoIzq, $PuntoCentro, $PuntoDr]

func _ready() -> void:
	#Pinta el obstáculo en un punto aleatorio
	spawn_random_obstacle()
	spawn_obstacles_and_collectibles()

func spawn_obstacles_and_collectibles() -> void:
	# 1. Instanciar un coleccionable aleatorio en uno de los carriles
	if databit_scene:
		var point_for_coin = spawn_points[randi() % spawn_points.size()]
		var coin = databit_scene.instantiate() as Node3D
		point_for_coin.add_child(coin)

func spawn_random_obstacle() -> void:
	# Elección aleatoria de carril (0: Izquierda, 1: Centro, 2: Derecha)
	var random_index = randi() % spawn_points.size()
	var selected_point = spawn_points[random_index]

	# Elección aleatoria de obstáculo
	var chance = randf()

	if chance < 0.5 and pared_verde_scene:
		# El Muro Verde se instancia en el centro exacto cubriendo los tres carriles
		var muro = pared_verde_scene.instantiate() as Node3D
		muro.position = Vector3(0, 2.5, -10) # Colocado a mitad de un bloque de 20m
		add_child(muro)
		
	elif piramide_scene:
		var piramide = piramide_scene.instantiate() as Node3D
		selected_point.add_child(piramide)
