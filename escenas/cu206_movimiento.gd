# Nombre archivo: cu206_movimiento 
# Versión: v1.3
# Descripción: Referencia del HUD
# Autor: Aideé Vanessa Casillas Tapia

extends CharacterBody3D

# Variables configurables desde el Inspector
@export_group("Movimiento")
@export var forward_speed: float = 12.0     # Velocidad constante de avance
@export var lane_distance: float = 3.0      # Distancia entre carriles (eje X)
@export var lane_change_speed: float = 15.0 # Velocidad de cambio de carril
@export var jump_velocity: float = 8.0      # Fuerza de salto

# --- RECURSOS DE MATERIALES (Pre-cargados) ---
@export_group("Materiales de Fases")
@export var mat_normal: Material
@export var mat_stdin: Material
@export var mat_stdout: Material
@export var mat_stderr: Material

# Enum para los estados/fases
enum Phase { NORMAL, STDIN, STDOUT, STDERR }
var current_phase: Phase = Phase.NORMAL

@export_group("Mecánica Overclock")
@export var boost_speed: float = 22.0       # Velocidad durante Overclock Boost

# Estado interno
var current_lane: int = 0  # -1: Izquierda, 0: Centro, 1: Derecha
var target_x: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var mesh_node: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Establecer material inicial
	set_phase(Phase.NORMAL)

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad si está en el aire
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Entrada de Usuario - Cambio de Carriles (Izquierda / Derecha)
	if Input.is_action_just_pressed("ui_left") and current_lane > -1:
		current_lane -= 1
	elif Input.is_action_just_pressed("ui_right") and current_lane < 1:
		current_lane += 1

	# Calcular posición X objetivo según el carril activo
	target_x = current_lane * lane_distance
	
	# Interpolar suavemente la posición X actual hacia el carril objetivo
	var current_pos = global_position
	current_pos.x = move_toward(current_pos.x, target_x, lane_change_speed * delta)
	global_position.x = current_pos.x
	
	# 3. Controles de Fases (Teclas 1, 2, 3 o Teclas A, S, D)
	if Input.is_key_pressed(KEY_1):
		set_phase(Phase.NORMAL)
	elif Input.is_key_pressed(KEY_2):
		set_phase(Phase.STDIN)   # Fase Verde
	elif Input.is_key_pressed(KEY_3):
		set_phase(Phase.STDOUT)  # Fase Magenta
	elif Input.is_key_pressed(KEY_4):
		set_phase(Phase.STDERR)  # Fase Naranja

	# 4. Entrada de Usuario - Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 5. Entrada de Usuario - Overclock Boost (Mantener SHIFT / Tecla Aceptar)
	var active_speed = forward_speed
	if Input.is_action_pressed("ui_focus_next"): # Por defecto la tecla Tab/Shift
		active_speed = boost_speed

	# 5. Avance constante hacia adelante (eje -Z en Godot)
	velocity.z = -active_speed
	mesh_node.rotate_x(-active_speed * delta * 0.2)
	
	# Executar movimiento de físicas en Godot 4
	move_and_slide()

@onready var hud: CanvasLayer = $HUD 

# --- LÓGICA DE CAMBIO DE FASES Y FÍSICAS ---
func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	
	match current_phase:
		Phase.NORMAL:
			mesh_node.material_override = mat_normal
			# Choca con todo (Capas 1, 2, 3 y 4)
			set_collision_mask_value(1, true)  # Suelo
			set_collision_mask_value(2, true)  # Pared Verde
			set_collision_mask_value(3, true)  # Pared Magenta
			set_collision_mask_value(4, true)  # Pared Naranja
			if hud: hud.update_phase_display("NORMAL [AZUL]", "#00ffff")

		Phase.STDIN: # Verde Matrix
			mesh_node.material_override = mat_stdin
			# Choca con Suelo, Magenta y Naranja. ¡Desactiva Capa 2 (Pared Verde)!
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, false) # <-- Atraviesa Pared Verde
			set_collision_mask_value(3, true)
			set_collision_mask_value(4, true)
			if hud: hud.update_phase_display("STDIN [VERDE]", "#00ff00")

		Phase.STDOUT: # Magenta
			mesh_node.material_override = mat_stdout
			# Desactiva Capa 3 (Pared Magenta)
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, true)
			set_collision_mask_value(3, false) # <-- Atraviesa Pared Magenta
			set_collision_mask_value(4, true)
			if hud: hud.update_phase_display("STDOUT [MAGENTA]", "#ff00ff")	

		Phase.STDERR: # Naranja Glitch
			mesh_node.material_override = mat_stderr
			# Desactiva Capa 4 (Pared Naranja)
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, true)
			set_collision_mask_value(3, true)
			set_collision_mask_value(4, false) # <-- Atraviesa Pared Naranja
			if hud: hud.update_phase_display("STDERR [NARANJA]", "#ff6600")
