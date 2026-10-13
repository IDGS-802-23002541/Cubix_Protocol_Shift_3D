# Nombre archivo: glitch_pyramid
# Versión: v1.0
# Descripción: Colisión al detectar algo entrar al área
# Autor: Aideé Vanessa Casillas Tapia

extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# Verificar si el objeto que entró es el personaje principal (CU-206)
	if body.has_method("set_phase"):
		# Si CU-206 está en Fase STDERR (Naranja Glitch), destruye el obstáculo
		if body.current_phase == body.Phase.STDERR:
			print("¡Pirámide destruida por sobrecarga STDERR!")
			queue_free() # Elimina la pirámide del juego
		else:
			# Si está en cualquier otro color (Normal, Verde, Magenta), el jugador pierde/reinicia
			print("¡CU-206 sufrio un error critico por Malware!")
			get_tree().reload_current_scene() # Reinicia el nivel
