extends Node2D

var erizo_escena = load("res://scenes/enemies/erizo.tscn")

func _ready() -> void:
	var erizo_enemigo = erizo_escena.instantiate()
	add_child(erizo_enemigo)
	erizo_enemigo.position = Vector2(10,-80)
