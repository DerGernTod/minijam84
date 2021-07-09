extends Label

var target_fps := 0.0

func _ready() -> void:
	_update_label();

func _process(delta: float) -> void:
	if delta > 0:
		target_fps = 1.0 / delta;
	
func _update_label() -> void:
	while true:
		text = "%2.2f FPS" % target_fps;
		yield(get_tree().create_timer(0.5), "timeout");
