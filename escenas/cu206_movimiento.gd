# Nombre archivo: cu206_movimiento
# Versión: v2.0
# Descripción: Ordenado y optimizado con sistema de vidas y fases
# Autor: Aideé Vanessa Casillas Tapia

extends CharacterBody3D

@export_group("Movimiento y Velocidad")
@export var forward_speed: float = 12.0     # Velocidad constante de avance
@export var boost_speed: float = 22.0       # Velocidad durante Overclock Boost
@export var lane_distance: float = 4.5      # Distancia entre carriles (eje X)
@export var lane_change_speed: float = 15.0 # Velocidad de transición entre carriles
@export var jump_velocity: float = 8.0      # Fuerza de salto

@export_group("Sistema de Juego")
@export var max_health: int = 3             # Vidas máximas del jugador
@export var max_emp_energy: float = 100.0   # Energía máxima para pulso EMP

@export_group("Materiales de Fases")
@export var mat_normal: Material
@export var mat_stdin: Material
@export var mat_stdout: Material
@export var mat_stderr: Material

enum Phase { NORMAL, STDIN, STDOUT, STDERR }
var current_phase: Phase = Phase.NORMAL

var score: int = 0
var current_health: int = 3
var emp_energy: float = 0.0                 # Energía acumulada por RAM Bits para EMP

var current_speed: float = 12.0
var current_lane: int = 0                   # -1: Izquierda, 0: Centro, 1: Derecha
var target_x: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var mesh_node: MeshInstance3D = $MeshInstance3D
@onready var hud: CanvasLayer = $HUD

# CICLO DE VIDA (READY & PHYSICS_PROCESS)
func _ready() -> void:
	# Inicializar estados al arrancar
	set_phase(Phase.NORMAL)
	current_health = max_health
	update_hud_display()

func _physics_process(delta: float) -> void:
	# 1. Control de Velocidad (Overclock Boost con Shift o ui_accept)
	if Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SHIFT):
		current_speed = boost_speed
	else:
		current_speed = forward_speed
		
	# 2. Aplicar Gravedad si está en el aire
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 3. Entrada de Usuario - Cambio de Carriles (Izquierda / Derecha)
	if Input.is_action_just_pressed("ui_left") and current_lane > -1:
		current_lane -= 1
	elif Input.is_action_just_pressed("ui_right") and current_lane < 1:
		current_lane += 1

	# Interpolar suavemente la posición X hacia el carril objetivo
	target_x = current_lane * lane_distance
	var current_pos = global_position
	current_pos.x = move_toward(current_pos.x, target_x, lane_change_speed * delta)
	global_position.x = current_pos.x

	# 4. Entrada de Usuario - Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 5. Controles de Fases (Teclas 1, 2, 3, 4)
	if Input.is_key_pressed(KEY_1):
		set_phase(Phase.NORMAL)
	elif Input.is_key_pressed(KEY_2):
		set_phase(Phase.STDIN)   # Fase Verde (Alfa)
	elif Input.is_key_pressed(KEY_3):
		set_phase(Phase.STDOUT)  # Fase Magenta (Beta)
	elif Input.is_key_pressed(KEY_4):
		set_phase(Phase.STDERR)  # Fase Naranja (Gamma)

	# 6. Avance constante hacia adelante (eje -Z) y rotación estética del cubo
	velocity.z = -current_speed
	if mesh_node:
		mesh_node.rotate_x(-current_speed * delta * 0.2)
	
	# Ejecutar movimiento físico en Godot 4
	move_and_slide()

# SISTEMA DE PUNTANAJE, VIDAS Y ENERGÍA EMP
func add_score(amount: int) -> void:
	score += amount
	
	# Acumular energía EMP opcionalmente con los coleccionables (RAM Bits)
	emp_energy = min(emp_energy + 10.0, max_emp_energy)
	
	if hud and hud.has_method("update_score"):
		hud.update_score(score)
		
	print("Puntaje actual: ", score, " | Energía EMP: ", emp_energy)

func take_damage() -> void:
	# Evita que dos impactos en el mismo instante dejen las vidas en negativo
	if current_health <= 0:
		return
	current_health -= 1
	print("¡Alerta! Integridad comprometida. Vidas restantes: ", current_health)
	
	update_hud_display()
	
	if current_health <= 0:
		print("¡Fallo crítico del sistema! Reiniciando nivel...")
		set_physics_process(false)
		# Diferido: no se puede recargar la escena durante el callback de física
		get_tree().call_deferred("reload_current_scene")
	else:
		# Lógica de inmunidad temporal o parpadeo si se desea
		pass

func update_hud_display() -> void:
	if hud:
		if hud.has_method("update_lives"):
			hud.update_lives(current_health)
		# Si implementas la barra EMP en el HUD en el futuro:
		# if hud.has_method("update_emp"): hud.update_emp(emp_energy)

# LÓGICA DE CAMBIO DE FASES Y FILTRADO DE CAPAS DE COLISIÓN
func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	
	match current_phase:
		Phase.NORMAL:
			if mesh_node: mesh_node.material_override = mat_normal
			set_collision_mask_value(1, true)  # Suelo
			set_collision_mask_value(2, true)  # Pared Verde
			set_collision_mask_value(3, true)  # Pared Magenta
			set_collision_mask_value(4, true)  # Pared Naranja
			if hud and hud.has_method("update_phase_display"): 
				hud.update_phase_display("NORMAL [AZUL]", "#00ffff")

		Phase.STDIN: # Verde Matrix
			if mesh_node: mesh_node.material_override = mat_stdin
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, false) # Atraviesa Pared Verde
			set_collision_mask_value(3, true)
			set_collision_mask_value(4, true)
			if hud and hud.has_method("update_phase_display"): 
				hud.update_phase_display("STDIN [VERDE]", "#00ff00")

		Phase.STDOUT: # Magenta
			if mesh_node: mesh_node.material_override = mat_stdout
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, true)
			set_collision_mask_value(3, false) # Atraviesa Pared Magenta
			set_collision_mask_value(4, true)
			if hud and hud.has_method("update_phase_display"): 
				hud.update_phase_display("STDOUT [MAGENTA]", "#ff00ff")	

		Phase.STDERR: # Naranja Glitch
			if mesh_node: mesh_node.material_override = mat_stderr
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, true)
			set_collision_mask_value(3, true)
			set_collision_mask_value(4, false) # Atraviesa Pared Naranja
			if hud and hud.has_method("update_phase_display"): 
				hud.update_phase_display("STDERR [NARANJA]", "#ff6600")
