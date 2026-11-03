# Nombre archivo: track_manager
# Versión: v3.2 (Generación infinita corregida)
# Descripción: Gestor de pista infinita estable para runner
# Autor: Aideé Vanessa Casillas Tapia

extends Node3D

@export var block_scene: PackedScene      # Asigna BloquePista.tscn en el Inspector
@export var player: Node3D                # Debe apuntar al CharacterBody3D que se mueve (CU-206/CharacterBody3D)
@export var block_length: float = 25.0    # Longitud exacta de cada bloque (25 metros)
@export var spawn_distance_ahead: float = 300.0 # Distancia a mantener construida por delante
@export var max_blocks: int = 20          # Límite de bloques en memoria

var active_blocks: Array[Node3D] = []

func _ready() -> void:
	_resolve_player()

	# Si ya hay bloques colocados en la escena de forma manual al iniciar, los detectamos
	for child in get_children():
		if child is Node3D and (child.name.begins_with("Bloque") or _is_block_scene(child)):
			active_blocks.append(child)

	if active_blocks.is_empty():
		# Generamos pista inicial suficiente para cubrir toda la distancia por delante
		var blocks_needed := int(ceil(spawn_distance_ahead / block_length)) + 1
		for i in range(blocks_needed):
			spawn_initial_block(-i * block_length)
	else:
		# Ordenar los bloques existentes por su posición Z (de atrás hacia adelante)
		active_blocks.sort_custom(func(a, b): return a.global_position.z < b.global_position.z)
		_ensure_track_ahead()

	# Evitamos liberar bloques que todavía deben existir por delante del jugador
	var min_blocks := int(ceil(spawn_distance_ahead / block_length)) + 3
	if max_blocks < min_blocks:
		max_blocks = min_blocks

func _is_block_scene(node: Node) -> bool:
	return block_scene != null and node.scene_file_path == block_scene.resource_path

func _resolve_player() -> void:
	if is_instance_valid(player):
		return

	# 1) Por grupo (robusto ante cambios de jerarquía)
	player = get_tree().get_first_node_in_group("player") as Node3D

	# 2) Por ruta directa al cuerpo del jugador
	if not is_instance_valid(player):
		player = get_node_or_null("../CU-206/CharacterBody3D") as Node3D

	# 3) Último recurso: el nodo contenedor
	if not is_instance_valid(player):
		player = get_node_or_null("../CU-206") as Node3D

	if not is_instance_valid(player):
		push_warning("TrackManager: no se encontró el jugador. La pista no se generará.")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	_ensure_track_ahead()

func _ensure_track_ahead() -> void:
	if not block_scene or active_blocks.is_empty():
		return

	var furthest := _get_furthest_block()
	if furthest == null:
		return

	# Distancia (positiva) de pista que aún queda por delante del jugador.
	# Avanzamos hacia -Z, por eso es player.z - furthest.z.
	var distance_ahead := player.global_position.z - furthest.global_position.z

	# "while" por si hace falta crear más de un bloque en el mismo frame.
	# El límite de iteraciones evita cualquier bucle infinito si algo falla.
	var guard := 0
	while distance_ahead < spawn_distance_ahead and guard < 32:
		guard += 1

		spawn_next_block()

		cleanup_old_blocks()

		furthest = _get_furthest_block()
		if furthest == null:
			break

		distance_ahead = player.global_position.z - furthest.global_position.z

func _get_furthest_block() -> Node3D:
	# El bloque más adelantado es el de menor Z (avanzamos hacia -Z)
	var furthest: Node3D = null
	for block in active_blocks:
		if not is_instance_valid(block):
			continue
		if furthest == null or block.global_position.z < furthest.global_position.z:
			furthest = block
	return furthest

func spawn_initial_block(target_z: float) -> void:
	if not block_scene: return
	var new_block = block_scene.instantiate() as Node3D
	add_child(new_block)
	new_block.global_position = Vector3(0, 0, target_z)
	active_blocks.append(new_block)

func spawn_next_block() -> void:
	if not block_scene: return

	var furthest := _get_furthest_block()
	if furthest == null: return

	var new_block = block_scene.instantiate() as Node3D
	add_child(new_block)

	# Continuamos avanzando en -Z a partir del bloque más adelantado
	var next_z = furthest.global_position.z - block_length

	new_block.global_position = Vector3(0, 0, next_z)
	active_blocks.append(new_block)

func cleanup_old_blocks() -> void:
	# Quitar referencias inválidas antes de contar
	for i in range(active_blocks.size() - 1, -1, -1):
		if not is_instance_valid(active_blocks[i]):
			active_blocks.remove_at(i)

	# Eliminar bloques que ya quedaron muy atrás del jugador para liberar memoria
	while active_blocks.size() > max_blocks:
		var old_block = active_blocks.pop_front()
		if is_instance_valid(old_block):
			old_block.queue_free()
