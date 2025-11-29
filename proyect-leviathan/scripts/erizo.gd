extends "res://scripts/base_enemy.gd"

func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("idle")
	
	speed = 500
	max_hp = 1
	damage = 4
	
	velocity = Vector2(-200,-250).normalized() * speed

func behaviour(delta:float):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
