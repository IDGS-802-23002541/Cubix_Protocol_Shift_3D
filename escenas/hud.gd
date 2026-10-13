# Nombre archivo: hud
# Versión: v1.0
# Descripción: CanvasLayer
# Autor: Aideé Vanessa Casillas Tapia

extends CanvasLayer

@onready var label_fase: Label = $UIBase/LabelFase
@onready var label_estado: Label = $UIBase/LabelEstado

# Función pública para actualizar el texto de la fase desde CU-206
func update_phase_display(phase_name: String, color_hex: String) -> void:
	label_fase.text = "FASE: " + phase_name
	label_fase.modulate = Color(color_hex) # Cambia el color del texto dinámicamente
