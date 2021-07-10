extends Area2D
class_name Customer

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var speed := 1
export var required_bubbles := {
	BubbleColors.RED: 1,
	BubbleColors.GREEN: 1,
	BubbleColors.BLUE: 1,
} setget set_required_bubbles

func _ready() -> void:
	pass


func set_required_bubbles(required: Dictionary) -> void:
	required_bubbles = required


func _physics_process(delta: float) -> void:
	var player_pos = $"/root/Main/Player".global_position
	var target_dir = player_pos - position
	position += speed * target_dir.normalized()
	
	for body in get_overlapping_areas():
		if body is Bubble and collision_mask & body.collision_layer:
			_eat_bubble(body.bubble_type)
			body.queue_free()
		if body is Player:
			var customers = get_tree().get_nodes_in_group("customers")
			for customer in customers:
				customer.set_physics_process(false)
			yield(body.get_stunned(required_bubbles), "completed")
			for customer in customers:
				customer.set_physics_process(true)
			queue_free()


func _eat_bubble(bubble_type: int) -> void:
	if required_bubbles.has(bubble_type):
		required_bubbles[bubble_type] -= 1
		if required_bubbles[bubble_type] <= 0:
			required_bubbles.erase(bubble_type)
	
	if required_bubbles.empty():
		_kill()


func _kill() -> void:
	queue_free()

