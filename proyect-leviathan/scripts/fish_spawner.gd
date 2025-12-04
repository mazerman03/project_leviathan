extends Node2D

@export var fish_scene: PackedScene
@export var player: CharacterBody2D

func spawn_fish():
	if fish_scene == null:
		print("so, no fish?")
		return
	
	var fish = fish_scene.instantiate()
	
	get_parent().add_child(fish)
	
	fish.global_position = global_position + Vector2(randi()%10 * 50,randi()%10 * 50)
	fish.player = player
