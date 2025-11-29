extends CharacterBody2D

@export var max_hp: int
@export var speed: float
@export var damage: int

var hp: int

func _ready() -> void:
	hp = max_hp

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()

func die():
	print("enemy killed")
	$AnimatedSprite2D.play("death")
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))

func behaviour(delta:float):
	pass

func _physics_process(delta: float) -> void:
	behaviour(delta)
	#move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
