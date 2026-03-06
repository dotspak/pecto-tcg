extends Node2D
class_name Card

signal cardHovered
signal cardUnHovered

@onready var scaler : Node2D = $scaler

var handPos : Vector2 = Vector2.ZERO

func _ready(): get_parent().connect_card_signals(self)
func _on_area_2d_mouse_exited() -> void: cardUnHovered.emit()
func _on_area_2d_mouse_entered() -> void: cardHovered.emit()