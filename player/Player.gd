extends Area2D
class_name Player

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

signal out_of_ammo
signal stun_started
signal stun_ended

export var speed := 100.0
export var damping := 1.0
export var bounds := 50.0
export var bubble_spawn := Vector2(0, 0)
export var max_ammo := 30

var velocity := 0.0
var ammo := []
var cup_bubbles = {
	BubbleColors.RED: [],
	BubbleColors.GREEN: [],
	BubbleColors.BLUE: [],
}
var cur_bubbles = []
var is_dead := false

onready var screen_width := get_viewport_rect().size.x
onready var bubble_scene := preload("res://bubble/Bubble.tscn")
onready var cup_bubble_scene := preload("res://player/CupBubble.tscn")
onready var audio_shoot := preload("res://player/shoot.ogg")
onready var straw_top := $StrawTop
onready var audio_player := $ShootAudioPlayer
onready var audio_player_move := $MoveAudioPlayer
var init_face_pos
onready var anim := $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	yield($"/root/Main", "ready")
	for i in 30:
		add_ammo(randi() % BubbleColors.size())
	for i in 4:
		_create_bubble()


func add_ammo(type: int) -> void:
	if ammo.size() >= max_ammo:
		return
	
	ammo.push_back(type)
	var cup_bubble = cup_bubble_scene.instance()
	cup_bubble.modulate = Globals.COLOR_MAP[type]
	cup_bubbles[type].push_back(cup_bubble)
	$"/root/Main".add_child(cup_bubble)
	cup_bubble.global_position = global_position
	
	
func set_stunned(stunned: bool, origin: Vector2 = Vector2.ZERO) -> void:
	set_physics_process(!stunned)
	if stunned:
		velocity = 0
		audio_player_move.stop()
		anim.frame = 1
		emit_signal("stun_started")
		straw_top.look_at(origin)
	else:
		anim.frame = 0
		emit_signal("stun_ended")


func _remove_ammo() -> int:
	var ind = randi() % ammo.size()
	var type = ammo[ind]
	cup_bubbles[type].pop_front().queue_free()
	ammo.remove(ind)
	return type


func _physics_process(delta: float) -> void:
	if abs(velocity) > 5 and not audio_player_move.playing:
		pass
		#audio_player_move.play()
	if abs(velocity) <= 5:
		audio_player_move.stop()
	if Input.is_action_pressed("ui_left"):
		velocity -= speed * delta
	if Input.is_action_pressed("ui_right"):
		velocity += speed * delta
	
	velocity = lerp(velocity, 0, damping * delta)
	position.x = clamp(position.x + velocity * delta, bounds, screen_width - bounds)
	# cur_bubble.position = bubble_spawn
	
	var mouse_pos = get_viewport().get_mouse_position()
	var face_target = global_position + (mouse_pos - global_position).normalized() * 10
	anim.global_position = lerp(anim.global_position, face_target, delta * 5)
	$StrawTop.look_at(mouse_pos)
	if Input.is_action_just_pressed("ui_accept"):
		var target = mouse_pos - $StrawTop.global_position
		_fire_bubble(target.normalized())


func _create_bubble() -> void:
	var new_bubble = null
	
	if ammo.size() > 0:
		var new_bubble_type = _remove_ammo()
		new_bubble = bubble_scene.instance()
		new_bubble.set_bubble_type(new_bubble_type)
		new_bubble.visible = false
		$StrawTop.add_child(new_bubble)
		new_bubble.position = Vector2.ZERO
		cur_bubbles.append(new_bubble)
	var target_pos = Vector2(-24, 0)
	var tween_time = 0
	for i in cur_bubbles.size():
		tween_time = cur_bubbles[i].move_to_target(bubble_spawn + target_pos * i)
	
	yield(get_tree().create_timer(tween_time * 0.3), "timeout")
	
	if new_bubble:
		new_bubble.visible = true
	
	yield(get_tree().create_timer(tween_time * 0.7), "timeout")
	

func _fire_bubble(direction: Vector2) -> void:
	var oldest_bubble = cur_bubbles.pop_front()
	if not oldest_bubble:
		return
	audio_player.stream = audio_shoot
	audio_player.play()
	var old_pos = oldest_bubble.global_position
	$StrawTop.remove_child(oldest_bubble)
	$"/root/Main".add_child(oldest_bubble)
	oldest_bubble.global_position = old_pos
	oldest_bubble.fire(direction)
	_create_bubble()
	
	if cur_bubbles.size() == 0:
		_kill()

func _kill() -> void:
	set_physics_process(false)
	emit_signal("out_of_ammo")
	is_dead = true
	anim.frame = 1


func lose_bubble() -> int:
	yield(get_tree(), "idle_frame")
	if cur_bubbles.size() == 0:
		return -1
	var oldest_bubble = cur_bubbles.pop_front() as Bubble
	var type = oldest_bubble.bubble_type
	oldest_bubble.queue_free()
	yield(_create_bubble(), "completed")
	if cur_bubbles.size() == 0:
		_kill()
	return type


# TODO: we can't pass in customer here
#func get_stunned(customer: Customer) -> void:
#	var required_bubbles = customer.required_bubbles
#	set_physics_process(false)
#	while not required_bubbles.empty():
#		var oldest_bubble = cur_bubbles.pop_front() as Bubble
#		var type = oldest_bubble.bubble_type
#		# as long as we're missing required bubbles AND there's an oldest bubble, suck it up
#		customer.eat_bubble(type)
#
#		oldest_bubble.queue_free()
#		yield(_create_bubble(), "completed")
#		if cur_bubbles.size() == 0:
#			_kill()
#			return
#	yield(get_tree(), "idle_frame")
#
#	set_physics_process(true)
