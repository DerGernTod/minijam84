extends Area2D;

export var speed := 100.0;
export var damping := 1.0;
export var bounds := 50.0;
export var bubble_spawn := Vector2(0, 0);

var velocity := 0.0;
var cur_bubble: Bubble;

onready var screen_width := get_viewport_rect().size.x;
onready var bubble_scene := preload("res://bubble/Bubble.tscn");
onready var straw_top := $StrawTop;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_bubble();


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		velocity -= speed * delta;
	if Input.is_action_pressed("ui_right"):
		velocity += speed * delta;
	
	velocity = lerp(velocity, 0, damping * delta);
	position.x = clamp(position.x + velocity * delta, bounds, screen_width - bounds);
	cur_bubble.position = bubble_spawn;
	
	var mouse_pos = get_viewport().get_mouse_position();
	$StrawTop.look_at(mouse_pos);
	if Input.is_action_just_pressed("ui_accept"):
		var target = mouse_pos - $StrawTop.global_position;
		_fire_bubble(target.normalized());


func _create_bubble() -> void:
	cur_bubble = bubble_scene.instance();
	$StrawTop.add_child(cur_bubble);
	cur_bubble.position = bubble_spawn;


func _fire_bubble(direction: Vector2) -> void:
	var old_pos = cur_bubble.global_position;
	$StrawTop.remove_child(cur_bubble);
	$"/root/Main".add_child(cur_bubble);
	cur_bubble.global_position = old_pos;
	cur_bubble.fire(direction);
	_create_bubble();
