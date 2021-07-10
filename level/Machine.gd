extends Area2D

export var processing_time := 5.0

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum MachineState {
	IDLE,
	RUNNING,
	READY,	
}

var _state = MachineState.IDLE
var _player_was_here = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var areas = get_overlapping_areas()
	var player_is_here = false
	for area in areas:
		if area is Player:
			player_is_here = true
			if Input.is_action_just_pressed("ui_up"):
				_handle_action_press(area)
	if player_is_here and not _player_was_here:
		# enable highlight
		pass
	if _player_was_here and not player_is_here:
		# disable highlight
		pass
	_player_was_here = player_is_here


func _handle_action_press(player: Player) -> void:
	match _state:
		MachineState.IDLE:
			_state = MachineState.RUNNING
			yield(get_tree().create_timer(processing_time), "timeout")
			_state = MachineState.READY
		MachineState.RUNNING:
			pass
		MachineState.READY:
			_state = MachineState.IDLE
			player.add_ammo(randi() % 3)
			pass
