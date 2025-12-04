extends "res://scripts/base_enemy.gd"

func _ready() -> void:
	
	speed = 500
	max_hp = 25
	damage = 15
	
	super()

func behaviour(delta:float):
	
	if player:
		var dir = (player.global_position - global_position).normalized()
		var ang = atan2(dir.y, dir.x)
		
		velocity = dir * speed
		
		if ang > PI/2 or ang < -PI/2:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		rotation = ang
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
