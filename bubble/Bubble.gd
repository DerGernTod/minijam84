extends Area2D;
class_name Bubble

const BubbleColors = preload("res://utils/GlobalEnums.gd").BubbleColors
const COLOR_MAP = {
	BubbleColors.BLUE: Color("#c04287f5"),
	BubbleColors.GREEN: Color("#c042f57b"),
	BubbleColors.RED: Color("#c0f55142"),
}

export var impulse_force := 1.0
export var tween_time := 0.5

var bubble_type: int = BubbleColors.RED setget set_bubble_type
var velocity := Vector2.ZERO

onready var sprite := $Sprite
onready var tween : Tween = $Tween

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 0
	set_bubble_type(bubble_type)


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _update_position(updated: Vector2) -> void:
	position = updated


func move_to_target(target: Vector2) -> float:
	tween.interpolate_method(self, "_update_position", position, target, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT) 
	tween.start()
	return tween_time


func set_bubble_type(type: int) -> void:
	bubble_type = type
	if sprite:
		sprite.modulate = COLOR_MAP[type]


func fire(direction: Vector2) -> void:
	collision_layer = 1
	velocity += direction * impulse_force
	pass
