extends Node2D

const customer_scene := preload("res://customer/Customer.tscn")

export var spawn_height_perc := 0.8

onready var timer := $Timer
onready var viewport_rect := get_viewport_rect().size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.connect("timeout", self, "_spawn");
	

func _spawn() -> void:
	var customer = customer_scene.instance();
	$"/root/Main".add_child(customer)
	customer.position = Vector2(rand_range(0, viewport_rect.x), viewport_rect.y * spawn_height_perc)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
