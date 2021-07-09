extends Area2D
class_name Customer

# const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var required_bubbles := {
	"red": 1,
	"green": 1,
	"blue": 1,
}

var collected_bubbles := {
	"red": 0,
	"green": 0,
	"blue": 0,
}

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Bubble:
			_eat_bubble(body.bubble_type)
			body.queue_free()


func _eat_bubble(bubble_type: String) -> void:
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

