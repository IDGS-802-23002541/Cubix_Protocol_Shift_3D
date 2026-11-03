# Nombre archivo: data_bit
# Versión: v1.0
# Descripción: Puntos para CU-206
# Autor: Aideé Vanessa Casillas Tapia

extends Area3D

@export var score_value: int = 10

func _on_body_entered(body: Node3D) -> void:
	# Si el objeto que entra tiene la función add_score (es CU-206)
	if body.has_method("add_score"):
		body.add_score(score_value)
		queue_free() # Destruye el DataBit tras recogerlo
