extends CharacterBody2D

#@onready var main = get_tree().get_root().get_node("ass")
@onready var main = get_tree().current_scene
@onready var bullet = load("res://scenes/bullet.tscn")

#mouse vars
var cateto_opuesto: float
var hipotenusa: float
var angulo_mouse: float

#health vars
var MAX_HP = 100
var HP: int
var is_immune: bool = false
@export var immune_time: float = 2.0

# Variable in charge of the shooting mode
var mode: int = 0
var weapon_timer: Timer

var fire_delay = 200
# fire delay modifier
var modifier = 1
var last_fire_time = 0

# Movimiento en el agua
const WATER_GRAVITY = 400.0          
const MAX_FALL_SPEED = 1200.0         
const DIVE_SPEED = 800.0            

#velocidad del boost/flap haceindolo rapido en ambas direcciones
const FLAP_VELOCITY = -800.0        
const FLAP_DIAGONAL_SPEED = 500.0    

#velocidad cuando no este haciendo boost/flap
const MOVE_SPEED = 1000.0               

var is_flap_boosting: bool = false


func _ready() -> void:
	randomize()
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("idle")
	HP = MAX_HP
	
	weapon_timer = Timer.new()
	add_child(weapon_timer)
	weapon_timer.one_shot = true
	weapon_timer.connect("timeout", Callable(self, "_on_weapon_timer_timeout"))
	start_weapon_timer()

func _on_weapon_timer_timeout():
	
	var ws = $"../UI/weapon_selected"
	
	mode = randi()%3
	
	if mode == 0:
		ws.show()
		ws.play("single")
	elif mode == 1:
		ws.show()
		ws.play("triple")
	else:
		ws.show()
		ws.play("evoker")
	
	start_weapon_timer()

func die():
	$AnimatedSprite2D.play("death")
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_death_animation_finished"))
	play_sound("res://assets/sounds/explode.mp3")

func play_sound(path:String):
	var player = AudioStreamPlayer2D.new()
	add_child(player)
	player.stream = load(path)
	player.play()

func take_damage(amount: int):
	
	if is_immune:
		return
	
	play_sound("res://assets/sounds/damage.mp3")
	
	HP -= amount
	
	if HP <= 100 and HP > 75:
		$"../UI/healthbar".play("100")
	elif HP <= 75 and HP > 50:
		$"../UI/healthbar".play("75")
	elif HP <= 50 and HP > 25:
		$"../UI/healthbar".play("50")
	else:
		$"../UI/healthbar".play("25")
	
	if HP <= 0:
		die()
	else:
		become_immune()

func become_immune():
	is_immune = true
	
	#blinker
	$AnimatedSprite2D.modulate = Color(1.0, 0.0, 0.0, 0.502)
	
	#immunity timer
	var t = Timer.new()
	t.wait_time = immune_time
	t.one_shot = true
	t.connect("timeout", Callable(self, "_end_immune"))
	add_child(t)
	t.start()

func _end_immune():
	is_immune = false
	$AnimatedSprite2D.modulate = Color(1,1,1,1)	

func _play_idle_anim():
	$AnimatedSprite2D.play("idle")

func start_weapon_timer():
	weapon_timer.wait_time = randf_range(1,3)
	weapon_timer.start()

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
	
	play_sound("res://assets/sounds/shoot.mp3")
	
	shoot_angle(angulo_mouse)

func triple_shot():
	
	play_sound("res://assets/sounds/shoot3.mp3")
	
	for i in [-1, 0, 1]:
		shoot_angle(angulo_mouse + i*57.29)
	
func evoker_shot():
	
	play_sound("res://assets/sounds/evoker.mp3")
	
	
	for i in range(50):
			shoot_angle(angulo_mouse,Vector2(global_position.x - 25 - i*15, global_position.y))
			await get_tree().create_timer(0.01).timeout  # <-- delay por bala

func _physics_process(delta: float) -> void:
	
	# Get the input direction and handle the movement/deceleration.
	var x_input := Input.get_axis("left", "right")
	
	#Todo lo del dive para q baje en fa, y hacer como q flote cuando baja sin presionar espacio 
	if Input.is_action_pressed("down"):
		velocity.y = DIVE_SPEED
		$AnimatedSprite2D.play("down")
		if not $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_play_idle_animation")):
			$AnimatedSprite2D.connect("animation_finished", Callable(self, "_play_idle_animation"))
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
		$AnimatedSprite2D.play("up")
		if not $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_play_idle_animation")):
			$AnimatedSprite2D.connect("animation_finished", Callable(self, "_play_idle_animation"))
		play_sound("res://assets/sounds/floatup.mp3")
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
				fire_delay = 50 * modifier
			elif mode == 1:
				triple_shot()
				fire_delay = 100 * modifier
			elif mode == 2:
				evoker_shot()
				fire_delay = 300 * modifier
			
			last_fire_time = Time.get_ticks_msec()

	move_and_slide()
	
	#check collision
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision:
			var collider := collision.get_collider()
			if collider and collider.is_in_group("enemies"):
				take_damage(collider.damage)

func _input(event):
	if event is InputEventMouseMotion:
		var center = get_viewport_rect().size/2
		
		var dir = event.position - center
		
		angulo_mouse = atan2(dir.y, dir.x) + PI/2

func _on_death_animation_finished() -> void:
	queue_free()


func _on_weapon_selected_animation_finished() -> void:
	$"../UI/weapon_selected".hide()
