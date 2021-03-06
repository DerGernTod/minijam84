extends Node2D

const customer_scene := preload("res://customer/Customer.tscn")
const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors

signal customer_satisfied

export var spawn_height_perc := 0.8

onready var spawn_timer := $SpawnTimer
onready var difficulty_timer := $DifficultyTimer
onready var viewport_rect := get_viewport_rect().size
onready var init_wait_time:float = $SpawnTimer.wait_time

var difficulty := 1.0


func _ready() -> void:
	spawn_timer.connect("timeout", self, "_spawn")
	difficulty_timer.connect("timeout", self, "_increase_difficulty")


func _increase_difficulty() -> void:
	difficulty += 0.1


func pause_enemies(pause: bool) -> void:
	spawn_timer.paused = pause
	difficulty_timer.paused = pause
	for customer in get_tree().get_nodes_in_group("customers"):
		customer.set_paused(pause)


func _customer_suck_started() -> void:
	pause_enemies(true)
	

func _customer_suck_ended() -> void:
	pause_enemies(false)
	

func _customer_satisfied() -> void:
	emit_signal("customer_satisfied")


func _spawn() -> void:
	spawn_timer.wait_time = init_wait_time / difficulty
	
	var customer = customer_scene.instance()
	$"/root/Main".add_child(customer)
	customer.connect("suck_started", self, "_customer_suck_started")
	customer.connect("suck_ended", self, "_customer_suck_ended")
	customer.connect("satisfied", self, "_customer_satisfied")
	customer.position = Vector2(rand_range(0, viewport_rect.x), viewport_rect.y * spawn_height_perc)

	var total_num_requirements = floor(rand_range(1, difficulty))
	var requirements: Dictionary = {}
	for val in total_num_requirements:
		var color = randi() % BubbleColors.size()
		var req = requirements[color] if requirements.has(color) else 0
		req += 1
		requirements[color] = req
	customer.set_required_bubbles(requirements)
	print("difficulty: %s. setting customer requirements to %s" % [difficulty, requirements])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
