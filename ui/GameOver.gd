extends Panel

onready var _tween = $Tween
onready var _play_button = $VBoxContainer/HBoxContainer/PlayAgain
onready var _menu_button = $VBoxContainer/HBoxContainer/MainMenu

func _ready() -> void:
	_play_button.disabled = true
	_menu_button.disabled = true
	modulate.a = 0


func show() -> void:
	yield(get_tree().create_timer(2), "timeout")
	_tween.interpolate_method(self, "_set_alpha", 0.0, 1.0, 1.0)
	_tween.start()
	yield(_tween, "tween_completed")
	_play_button.disabled = false
	_menu_button.disabled = false
	

func _set_alpha(alpha: float) -> void:
	modulate.a = alpha
