extends Area2D
class_name MachineButton

signal player_entered
signal player_left

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var bubble_color := BubbleColors.RED

var _player_was_here := false

onready var _sprite := $Overlay

func set_active(active: bool) -> void:
	_sprite.visible = active


func _physics_process(delta: float) -> void:
	var areas = get_overlapping_areas()
	var player_is_here = false
	for area in areas:
		if area is Player:
			player_is_here = true
	if player_is_here and not _player_was_here:
		emit_signal("player_entered", bubble_color)
	if _player_was_here and not player_is_here:
		emit_signal("player_left", bubble_color)
	_player_was_here = player_is_here
