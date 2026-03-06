extends Node2D
class_name Zone

@onready var DEF_MODULATE : Color = modulate

var card : Card = null

func highlight_zone(highlight : bool = true) -> void:
    var tween := create_tween().set_trans(Tween.TRANS_SINE)
    if highlight: tween.tween_property(self, "modulate", Color.LIGHT_YELLOW, 0.1)
    else: tween.tween_property(self, "modulate", DEF_MODULATE, 0.1)

func has_card() -> bool: return card != null
func _on_area_2d_mouse_exited() -> void: if !has_card(): highlight_zone(false)
func _on_area_2d_mouse_entered() -> void: if !has_card(): highlight_zone(true)