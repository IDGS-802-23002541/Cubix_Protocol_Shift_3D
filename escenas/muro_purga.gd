# Nombre archivo: muro_purga
# Versión: v1.0
# Descripción: Movimiento y colisión muro de purga
# Autor: Aideé Vanessa Casillas Tapia

extends Area3D

# Velocidad ligeramente inferior al avance normal de CU-206
@export var purge_speed: float = 10.5

func _physics_process(delta: float) -> void:
	# El muro avanza constantemente en el eje -Z (persiguiendo al jugador)
	global_position.z -= purge_speed * delta

# Conecta la señal body_entered desde la pestaña "Nodos"
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("set_phase"):
		print("¡CU-206 fue alcanzado por la Purga del Virus T!")
		get_tree().reload_current_scene() # Reinicia el nivel
