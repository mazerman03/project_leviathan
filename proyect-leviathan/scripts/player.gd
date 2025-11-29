extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("ass")
@onready var bullet = load("res://scenes/bullet.tscn")

var MAX_HP = 100
var HP: int

# Variable in charge of the shooting mode
var mode: int = 0

var fire_delay = 200
# fire delay modifier
var modifier = 1
var last_fire_time = 0

# Movimiento en el agua
const WATER_GRAVITY = 400.0          
const MAX_FALL_SPEED = 150.0         
const DIVE_SPEED = 500.0            

#velocidad del boost/flap haceindolo rapido en ambas direcciones
const FLAP_VELOCITY = -300.0        
const FLAP_DIAGONAL_SPEED = 250.0    

#velocidad cuando no este haciendo boost/flap
const MOVE_SPEED = 150.0               

var is_flap_boosting: bool = false


func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("idle")

func change_mode():
	#just for debugging
	if mode != 2:
		mode += 1
	else:
		mode = 0

func can_shoot() -> bool:
	var now = Time.get_ticks_msec()
	return now - last_fire_time >= fire_delay

func shoot_angle(dir_angle, pos = global_position):
	var bullet_tmp = bullet.instantiate()
	bullet_tmp.dir = dir_angle
	bullet_tmp.spawnPos = pos
	bullet_tmp.spawnRot = dir_angle
	bullet_tmp.zdex = z_index -1
	main.add_child.call_deferred(bullet_tmp)

func single_shot():
	
	var direction := Input.get_axis("left","right")
	
	if direction != 0:
		shoot_angle(direction * PI/2)
	else:
		if Input.is_action_pressed("down"):
			shoot_angle(PI)
		else:
			shoot_angle(0)

func triple_shot():
	var direction := Input.get_axis("left","right")
	
	if direction != 0:
		shoot_angle(direction * PI * 1/4)
		shoot_angle(direction * PI * 1/2)
		shoot_angle(direction * PI * 3/4)
	else:
		if Input.is_action_pressed("down"):
			shoot_angle(PI * -3/4)
			shoot_angle(PI)
			shoot_angle(PI * 3/4)
		else:
			shoot_angle(PI * -1/4)
			shoot_angle(0)
			shoot_angle(PI * 1/4)

func evoker_shot():
	var direction := Input.get_axis("left", "right")
	
	if direction == -1:
		for i in range(6):
			shoot_angle(0,Vector2(global_position.x - 25 - i*50, global_position.y))
			await get_tree().create_timer(0.1).timeout  # <-- delay por bala
	else:
		for i in range(6):
			shoot_angle(0,Vector2(global_position.x + 25 + i*50, global_position.y))
			await get_tree().create_timer(0.1).timeout  # <-- delay por bala

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var x_input := Input.get_axis("left", "right")
	
	#Todo lo del dive para q baje en fa, y hacer como q flote cuando baja sin presionar espacio 
	if Input.is_action_pressed("down"):
		velocity.y = DIVE_SPEED
	else:
		if not is_on_floor():
			velocity.y += WATER_GRAVITY * delta
			if velocity.y > MAX_FALL_SPEED:
				velocity.y = MAX_FALL_SPEED

	# Handle jump.
	
	#Hacer el salto
	if Input.is_action_just_pressed("up"):
		velocity.y = FLAP_VELOCITY
		is_flap_boosting = true
	#tambien checamos hasta que lo suelta para mantener la velocidad si sigue presionando espacio
	if Input.is_action_just_released("up"):
		is_flap_boosting = false
	
	# Hacerlo rapido en el aire si mantiene espacio oprimido y hacerlo lento en el piso en general
	if not is_on_floor() and is_flap_boosting:
		velocity.x = x_input * FLAP_DIAGONAL_SPEED
	else:
		velocity.x = x_input * MOVE_SPEED
		
		# Handle shooting
	if Input.is_action_pressed("shoot"):
		if can_shoot():
			
			if mode == 0:
				single_shot()
				fire_delay = 150 * modifier
			elif mode == 1:
				triple_shot()
				fire_delay = 300 * modifier
			elif mode == 2:
				evoker_shot()
				fire_delay = 1000 * modifier
			
			last_fire_time = Time.get_ticks_msec()
	
	if Input.is_action_just_pressed("mode_changer"):
		change_mode()

	move_and_slide()
