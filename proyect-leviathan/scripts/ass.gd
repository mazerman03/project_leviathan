extends Node2D

var erizo_escena = load("res://scenes/enemies/erizo.tscn")
var blobfish_scene = load("res://scenes/enemies/blobfish.tscn")
var swordfish_scene = load("res://scenes/enemies/swordfish.tscn")

var timedown = 60
var counter: float

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$UI/healthbar.play("100")
	
	$swordfish_spawner.fish_scene = swordfish_scene
	$swordfish_spawner.player = $player
	
	for i in range(40):
		var erizo_enemigo = erizo_escena.instantiate()
		add_child(erizo_enemigo)
		
		var x = randi_range(100,300)
		var y = randi_range(50,200)
		var angle = randf() * PI
		erizo_enemigo.velocity = Vector2(cos(angle), sin(angle)) * erizo_enemigo.speed
		
		erizo_enemigo.position = Vector2(x,y)
	
	#for i in range(25):
		#var blobfish = blobfish_scene.instantiate()
		#add_child(blobfish)
		#blobfish.position = Vector2(-400, -720 + 50*i)
	
	for i in range(15):
		$swordfish_spawner.spawn_fish()

func _physics_process(delta: float) -> void:
	timedown -= delta
	counter += delta
	
	if counter >= 20:
		for i in range(15):
			$swordfish_spawner.spawn_fish()
		
		for i in range(40):
			var erizo_enemigo = erizo_escena.instantiate()
			add_child(erizo_enemigo)
		
			var x = randi_range(100,300)
			var y = randi_range(50,200)
			var angle = randf() * PI
			erizo_enemigo.velocity = Vector2(cos(angle), sin(angle)) * erizo_enemigo.speed
		
			erizo_enemigo.position = Vector2(x,y)
		
		counter = 0
	
	if timedown <= 0:
		get_tree().change_scene_to_file("res://scenes/ribs.tscn")
	
	$UI/Label.text = str(timedown)
