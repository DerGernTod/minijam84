extends Area2D

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

export var speed := 100.0
export var damping := 1.0
export var bounds := 50.0
export var bubble_spawn := Vector2(0, 0)

var velocity := 0.0
var cur_bubbles := []
var ammo := 10

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
	var i = 0;
	for bubble in cur_bubbles:
		i += 1
		if bubble is Bubble:
			bubble.move_to_target(bubble_spawn + target_pos * i)


func _fire_bubble(direction: Vector2) -> void:
	var oldest_bubble = cur_bubbles.pop_front()
	var old_pos = oldest_bubble.global_position
	$StrawTop.remove_child(oldest_bubble)
	$"/root/Main".add_child(oldest_bubble)
	oldest_bubble.global_position = old_pos
	oldest_bubble.fire(direction)
	_create_bubble()
	
	if cur_bubbles.size() == 0:
		ammo_hud.text = "just a regular tea"
		set_physics_process(false)
