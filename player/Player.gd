extends Area2D
class_name Player
const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

signal out_of_ammo

export var speed := 100.0
export var damping := 1.0
export var bounds := 50.0
export var bubble_spawn := Vector2(0, 0)

var velocity := 0.0
var ammo := 10
var cur_bubbles = []
var is_dead := false

onready var screen_width := get_viewport_rect().size.x
onready var bubble_scene := preload("res://bubble/Bubble.tscn")
onready var straw_top := $StrawTop
onready var ammo_hud := $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 4:
		_create_bubble()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		velocity -= speed * delta
	if Input.is_action_pressed("ui_right"):
		velocity += speed * delta
	
	velocity = lerp(velocity, 0, damping * delta)
	position.x = clamp(position.x + velocity * delta, bounds, screen_width - bounds)
	# cur_bubble.position = bubble_spawn
	
	var mouse_pos = get_viewport().get_mouse_position()
	$StrawTop.look_at(mouse_pos)
	if Input.is_action_just_pressed("ui_accept"):
		var target = mouse_pos - $StrawTop.global_position
		_fire_bubble(target.normalized())


func _create_bubble() -> void:
	ammo -= 1
	if ammo >= 0:
		ammo_hud.text = str(ammo)
		var new_bubble = bubble_scene.instance()
		new_bubble.set_bubble_type(randi() % BubbleColors.size())
		$StrawTop.add_child(new_bubble)
		new_bubble.position = bubble_spawn
		cur_bubbles.append(new_bubble)
	var target_pos = Vector2(-28, 0)
	var tweens = [];
	for i in cur_bubbles.size():
		tweens.append(cur_bubbles[i].move_to_target(bubble_spawn + target_pos * i))
		
	for tween in tweens:
		yield(tween, "completed")
	yield(get_tree(), "idle_frame")

func _fire_bubble(direction: Vector2) -> void:
	var oldest_bubble = cur_bubbles.pop_front()
	if not oldest_bubble:
		return
	var old_pos = oldest_bubble.global_position
	$StrawTop.remove_child(oldest_bubble)
	$"/root/Main".add_child(oldest_bubble)
	oldest_bubble.global_position = old_pos
	oldest_bubble.fire(direction)
	_create_bubble()
	
	if cur_bubbles.size() == 0:
		_kill()

func _kill() -> void:
	ammo_hud.text = "just a regular tea"
	set_physics_process(false)
	emit_signal("out_of_ammo")
	is_dead = true

func get_stunned(required_bubbles: Dictionary) -> void:
	set_physics_process(false)
	while not required_bubbles.empty():
		var oldest_bubble = cur_bubbles.pop_front() as Bubble
		var type = oldest_bubble.bubble_type
		# as long as we're missing required bubbles AND there's an oldest bubble, suck it up
		if required_bubbles.has(type):
			required_bubbles[type] -= 1
			if required_bubbles[type] <= 0:
				required_bubbles.erase(type)
		
		oldest_bubble.queue_free()
		yield(_create_bubble(), "completed")
		if cur_bubbles.size() == 0:
			_kill()
			return
	yield(get_tree(), "idle_frame")
	
	set_physics_process(true)
