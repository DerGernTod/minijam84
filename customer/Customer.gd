extends Area2D
class_name Customer

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var required_bubbles := {
	BubbleColors.RED: 1,
	BubbleColors.GREEN: 1,
	BubbleColors.BLUE: 1,
} setget set_required_bubbles

var collected_bubbles := {
	BubbleColors.RED: 0,
	BubbleColors.GREEN: 0,
	BubbleColors.BLUE: 0,
}


func _ready() -> void:
	pass


func set_required_bubbles(required: Dictionary) -> void:
	required_bubbles = required


func _physics_process(delta: float) -> void:
	for body in get_overlapping_areas():
		if body is Bubble:
			_eat_bubble(body.bubble_type)
			body.queue_free()


func _eat_bubble(bubble_type: int) -> void:
	collected_bubbles[bubble_type] += 1
	var done = true;
	for bubble in required_bubbles:
		if collected_bubbles[bubble] < required_bubbles[bubble]:
			done = false
			break
	if done:
		_kill()


func _kill() -> void:
	queue_free()

