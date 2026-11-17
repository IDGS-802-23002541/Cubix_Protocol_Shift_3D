# Nombre archivo: hud
# Versión: v1.2
# Descripción: CanvasLayer (label vidas)
# Autor: Aideé Vanessa Casillas Tapia

extends CanvasLayer

@onready var label_fase: Label = $UIBase/LabelFase
@onready var label_estado: Label = $UIBase/LabelEstado
@onready var label_puntaje: Label = $UIBase/LabelPuntaje
@onready var label_vidas: Label = $UIBase/LabelVidas

func _ready() -> void:
	# Inicializar los valores visuales base al arrancar la escena
	update_score(0)
	update_lives(3)

# Función pública para actualizar el texto de la fase desde CU-206
func update_phase_display(phase_name: String, color_hex: String) -> void:
	label_fase.text = "FASE: " + phase_name
	label_fase.modulate = Color(color_hex) # Cambia el color del texto dinámicamente

# Actualizar el marcador de puntos
func update_score(new_score: int) -> void:
	label_puntaje.text = "PUNTOS: " + str(new_score)
	
# Actualizar marcador de vidas
func update_lives(new_lives: int) -> void:
	label_vidas.text = "VIDAS: " + str(new_lives)
