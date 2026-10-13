# Nombre archivo: muro_verde
# Versión: v1.0
# Descripción: Asegura que esté en la capa 2 (STDIN)
# Autor: Aideé Vanessa Casillas Tapia

extends StaticBody3D

func _ready() -> void:
	# Asegura que el muro siempre pertenezca a la Capa 2 (Pared_Verde)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
