extends Panel


func _on_Play_button_up() -> void:
	get_tree().change_scene("res://ui/Tutorial.tscn")


func _on_Exit_button_up() -> void:
	get_tree().quit(0)
