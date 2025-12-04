extends "res://scripts/base_enemy.gd"

func _ready() -> void:
	
	speed = 10
	max_hp = 12
	damage = 1
	
	super()
	
	velocity = Vector2(-40,-50).normalized() * speed

func behaviour(delta:float):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
