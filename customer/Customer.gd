extends Area2D
class_name Customer

signal suck_started
signal suck_ended
signal satisfied

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var speed := 1
export var required_bubbles := {
	BubbleColors.RED: 1,
	BubbleColors.GREEN: 1,
	BubbleColors.BLUE: 1,
} setget set_required_bubbles

var _is_satisfied = false

onready var _screen_size = get_viewport_rect().size
onready var _tween = $Tween

func _ready() -> void:
	pass


func set_required_bubbles(required: Dictionary) -> void:
	required_bubbles = required


func _chase_player(delta: float) -> void:
	var player_pos = $"/root/Main/Player".global_position
	var target_dir = player_pos - position
	position += speed * target_dir.normalized() * delta
	
	for body in get_overlapping_areas():
		if body is Bubble and collision_mask & body.collision_layer:
			_eat_bubble(body.bubble_type)
			body.queue_free()
		
		if body is Player:
			emit_signal("suck_started")
			yield(body.get_stunned(required_bubbles), "completed")
			if not body.is_dead:
				emit_signal("suck_ended")
			_check_satisfied()


func _physics_process(delta: float) -> void:
	if not _is_satisfied:
		_chase_player(delta)


func _check_satisfied() -> void:
	if required_bubbles.empty():
		_is_satisfied = true
		_tween.interpolate_method(self, "_leave_shop", position, Vector2(randi() % int(_screen_size.x), _screen_size.y + 100), 8)
		_tween.start()
		yield(_tween, "tween_completed")
		_kill()


func _leave_shop(new_pos: Vector2) -> void:
	position = new_pos
	


func _eat_bubble(bubble_type: int) -> void:
	if required_bubbles.has(bubble_type):
		required_bubbles[bubble_type] -= 1
		if required_bubbles[bubble_type] <= 0:
			required_bubbles.erase(bubble_type)
	
	_check_satisfied()


func _kill() -> void:
	queue_free()

