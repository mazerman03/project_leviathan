extends CharacterBody2D

@export var max_hp: int
@export var speed: float
@export var damage: int
@export var player: CharacterBody2D

var hp: int
var current_color: Color

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	current_color = $AnimatedSprite2D.modulate
	hp = max_hp

func take_damage(amount: int):
	$AnimatedSprite2D.modulate = Color(1.0, 0.0, 0.0, 0.424)
	await get_tree().create_timer(.3).timeout
	$AnimatedSprite2D.modulate = current_color
	
	hp -= amount
	if hp <= 0:
		die()

func play_sound(path:String):
	var player = AudioStreamPlayer2D.new()
	add_child(player)
	player.stream = load(path)
	player.volume_db = -6
	player.play()

func die():
	$AnimatedSprite2D.play("death")	
	if not $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished")):
		$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))
	play_sound("res://assets/sounds/explode.mp3")

func behaviour(delta:float):
	pass

func _physics_process(delta: float) -> void:
	behaviour(delta)
	#move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
