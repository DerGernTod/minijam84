extends Area2D;

export var speed := 100.0;
export var damping := 1.0;
export var bounds := 50.0;

var velocity := 0.0;

onready var screen_width := get_viewport_rect().size.x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		velocity -= speed * delta;
	if Input.is_action_pressed("ui_right"):
		velocity += speed * delta;
	
	velocity = lerp(velocity, 0, damping * delta);
	position.x = clamp(position.x + velocity * delta, bounds, screen_width - bounds);
	
