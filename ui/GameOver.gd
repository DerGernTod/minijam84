extends Panel

onready var _tween = $Tween


func _ready() -> void:
	modulate.a = 0


func show() -> void:
	_tween.interpolate_method(self, "_set_alpha", 0.0, 1.0, 1.0)
	_tween.start()
	

func _set_alpha(alpha: float) -> void:
	modulate.a = alpha
