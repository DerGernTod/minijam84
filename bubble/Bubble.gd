extends RigidBody2D;
class_name Bubble

export var impulse_force := 1.0

var bubble_type: String = "red" setget set_bubble_type

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_bubble_type(type: String) -> void:
	bubble_type = type


func fire(direction: Vector2) -> void:
	apply_impulse(Vector2.ZERO, direction * impulse_force)
	pass
