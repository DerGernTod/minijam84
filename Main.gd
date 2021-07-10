extends Node2D

onready var player := $Player
onready var spawner := $CustomerSpawner

func _ready() -> void:
	player.connect("out_of_ammo", self, "_end_game")
	
func _end_game() -> void:
	spawner.pause_enemies(true)

