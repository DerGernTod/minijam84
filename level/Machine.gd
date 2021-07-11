extends Node2D

enum MachineState {
	IDLE,
	RUNNING,
	READY,	
}

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var processing_time := 5.0

var _state = MachineState.IDLE
var _active_button = null
var _prio_queue = []
var _processing_color = -1

onready var _anim_sprite = $AnimatedSprite
onready var colors = {
	BubbleColors.RED: $Red,
	BubbleColors.GREEN: $Green,
	BubbleColors.BLUE: $Blue,
}

func _ready() -> void:
	for col in BubbleColors.size():
		colors[col].connect("player_entered", self, "_player_entered")
		colors[col].connect("player_left", self, "_player_left")


func _player_entered(bubble_type: int) -> void:
	_prio_queue.push_back(bubble_type)

	if _active_button:
		_active_button.modulate = Color.white
	
	_active_button = colors[bubble_type]
	
	if _state != MachineState.RUNNING:
		_active_button.modulate = Color.green


func _player_left(bubble_type: int) -> void:
	var id = _prio_queue.find(bubble_type)
	_prio_queue.remove(id)
	
	if _active_button == colors[bubble_type]:
		_active_button.modulate = Color.white
	if _prio_queue.size() == 0:
		_active_button = null
	else:
		var type = _prio_queue[_prio_queue.size() - 1]
		_active_button = colors[type]
		if _state != MachineState.RUNNING:
			_active_button.modulate = Color.green


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		_handle_action_press()


func _handle_action_press() -> void:
	if not _active_button:
		return
	match _state:
		MachineState.IDLE:
			_processing_color = _active_button.bubble_color
			_state = MachineState.RUNNING
			_anim_sprite.frame = 1
			_active_button.modulate = Color.white
			yield(get_tree().create_timer(processing_time), "timeout")
			if _active_button:
				_active_button.modulate = Color.green
			_state = MachineState.READY
			_anim_sprite.frame = 2
		MachineState.RUNNING:
			pass
		MachineState.READY:
			_state = MachineState.IDLE
			for i in 10:
				$"/root/Main/Player".add_ammo(_processing_color)
			_processing_color = -1
			_anim_sprite.frame = 0


func _on_Player_out_of_ammo() -> void:
	set_physics_process(false)
