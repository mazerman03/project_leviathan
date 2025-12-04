extends Area2D

@export var speed: float = 700
var dir: float
var spawnPos: Vector2
var spawnRot: float
var zdex: int

func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")

	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex

	set_collision_layer_value(3, true) # layer 3
	set_collision_mask_value(2, true)  # mask 2

	connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func _physics_process(delta: float) -> void:
	global_position += Vector2(0, -speed).rotated(dir) * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(1)
		#body.die()
	queue_free()

func _on_life_timeout() -> void:
	queue_free()
