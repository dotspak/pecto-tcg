extends Node2D
class_name InputManager

signal leftbutton_clicked
signal leftbutton_released

const COLLISION_MASK_CARD : int = 1
const COLLISION_MASK_ZONE : int = 2
const COLLISION_MASK_DECK : int = 4

@onready var cardManager : CardManager = $"../CardManager"

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			leftbutton_clicked.emit()
			raycast_at_cursor()
		else:
			leftbutton_released.emit()


func raycast_at_cursor() -> void:
	var spaceState : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var paramters : PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	paramters.position = get_global_mouse_position()
	paramters.collide_with_areas = true

	var result : Array = spaceState.intersect_point(paramters)
	if !result.is_empty():
		var mask : int = result[0].collider.collision_mask
		if mask == COLLISION_MASK_CARD:
			# card clicked
			var cardFound : Card = result[0].collider.get_parent()
			if cardFound:
				cardManager.start_drag(cardFound)
		
		elif mask == COLLISION_MASK_DECK:
			cardManager.deck.draw_card()


func zone_check() -> Zone:
	var spaceState : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters : PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = InputManager.COLLISION_MASK_ZONE

	var result : Array = spaceState.intersect_point(parameters)
	return result[0].collider.get_parent() if !result.is_empty() else null
