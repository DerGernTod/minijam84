extends Node2D

var score := 0

onready var player := $Player
onready var spawner := $CustomerSpawner
onready var game_over := $CanvasLayer/GameOver
onready var game_over_score := $CanvasLayer/GameOver/VBoxContainer/VBoxContainer/SatisfiedCustomersCount
onready var ingame_score := $CanvasLayer/HBoxContainer/MarginContainer/Score

func _ready() -> void:
	player.connect("out_of_ammo", self, "_end_game")
	
func _end_game() -> void:
	spawner.pause_enemies(true)
	game_over.show()


func _on_PlayAgain_button_up() -> void:
	get_tree().reload_current_scene()


func _on_CustomerSpawner_customer_satisfied() -> void:
	score += 1
	game_over_score.text = str(score)
	ingame_score.text = str(score)


func _on_MainMenu_button_up() -> void:
	get_tree().change_scene("res://ui/MainMenu.tscn")
