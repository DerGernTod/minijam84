extends Area2D
class_name Customer

signal suck_started
signal suck_ended
signal satisfied

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors
const control_bubble_scene = preload("res://customer/ControlBubble.tscn")

export var speed := 1
export var required_bubbles := {
	BubbleColors.RED: 1,
	BubbleColors.GREEN: 1,
	BubbleColors.BLUE: 1,
} setget set_required_bubbles

var _is_satisfied = false
var _control_bubbles := {
	BubbleColors.RED: [],
	BubbleColors.GREEN: [],
	BubbleColors.BLUE: [],
}

onready var _screen_size = get_viewport_rect().size
onready var _tween = $Tween
onready var _control_bubble_container = $OrderBubble/GridContainer
onready var _audio = $AudioStreamPlayer2D
onready var _sprite = $Sprite

func _ready() -> void:
	pass


func set_required_bubbles(required: Dictionary) -> void:
	required_bubbles = required
	for color in required_bubbles:
		for count in required_bubbles[color]:
			var control_bubble = control_bubble_scene.instance()
			_control_bubble_container.add_child(control_bubble)
			control_bubble.modulate = Globals.COLOR_MAP[color]
			_control_bubbles[color].push_back(control_bubble)



func _chase_player(delta: float) -> void:
	var player_pos = $"/root/Main/Player/CollisionShape2D".global_position
	var target_dir = player_pos - position
	position += speed * target_dir.normalized() * delta
	if target_dir.x > 0: 
		_sprite.scale.x = -4
	else:
		_sprite.scale.x = 4
	for body in get_overlapping_areas():
		if body is Bubble and collision_mask & body.collision_layer:
			eat_bubble(body.bubble_type)
			body.queue_free()
		
		if body is Player:
			emit_signal("suck_started")
			body.set_stunned(true, global_position)
			while not _is_satisfied:
				var bubble_type = yield(body.lose_bubble(), "completed")
				if bubble_type < 0:
					return
				eat_bubble(bubble_type, true)
			
#			yield(body.get_stunned(self), "completed")
			if not body.is_dead:
				emit_signal("suck_ended")
				body.set_stunned(false)
			_check_satisfied()


func _physics_process(delta: float) -> void:
	if not _is_satisfied:
		_chase_player(delta)


func _check_satisfied() -> void:
	if required_bubbles.empty():
		emit_signal("satisfied")
		_is_satisfied = true
		_control_bubble_container.get_parent().queue_free()
		var target = Vector2(rand_range(_screen_size.x * 0.25, _screen_size.x * 0.75), _screen_size.y + 100)
		var target_dir = target - global_position
		if target_dir.x > 0: 
			_sprite.scale.x = -4
		else:
			_sprite.scale.x = 4
		
		_tween.interpolate_method(self, "_leave_shop", position, target, target_dir.length() / 500)
		_tween.start()
		yield(_tween, "tween_completed")
		_kill()


func _leave_shop(new_pos: Vector2) -> void:
	position = new_pos


func eat_bubble(bubble_type: int, always_play_sound = false) -> void:
	var is_required_bubble = required_bubbles.has(bubble_type)
	if always_play_sound or is_required_bubble:
		_audio.play(0)
	if is_required_bubble:
		required_bubbles[bubble_type] -= 1
		var control = _control_bubbles[bubble_type].pop_back()
		control.queue_free()
		if required_bubbles[bubble_type] <= 0:
			required_bubbles.erase(bubble_type)
			_control_bubbles.erase(bubble_type)
	
	_check_satisfied()


func _kill() -> void:
	queue_free()

