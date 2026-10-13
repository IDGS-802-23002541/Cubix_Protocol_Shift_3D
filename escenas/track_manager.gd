extends Node3D

@export var block_scene: PackedScene      # Asigna BloquePista.tscn
@export var player: Node3D                # Asigna al nodo CU-206
@export var block_length: float = 25.0    # Longitud de cada bloque
@export var initial_blocks: int = 5       # Cuántos bloques mantener activos

var spawn_z: float = 0.0                  # Posición Z donde colocar el siguiente bloque
var active_blocks: Array[Node3D] = []

func _ready() -> void:
	# Generar la pista inicial
	for i in range(initial_blocks):
		spawn_block()

func _process(_delta: float) -> void:
	if player:
		# Si el jugador se acerca al final de los bloques generados, crear uno nuevo
		if player.global_position.z - 100.0 < spawn_z:
			spawn_block()
			remove_old_block()

func spawn_block() -> void:
	if not block_scene: return
	
	var new_block = block_scene.instantiate() as Node3D
	add_child(new_block) # 1. Agregar PRIMERO al árbol de la escena
	new_block.global_position = Vector3(0, 0, spawn_z) # 2. LUEGO asignar la posición global
	
	active_blocks.append(new_block)
	spawn_z -= block_length
	

func remove_old_block() -> void:
	# Si hay demasiados bloques acumulados atrás, eliminar el más antiguo
	if active_blocks.size() > initial_blocks + 2:
		var old_block = active_blocks.pop_front()
		old_block.queue_free()
