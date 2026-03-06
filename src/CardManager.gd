extends Node2D
class_name CardManager


const HOVER_SCALE : Vector2 = Vector2.ONE * 2

@onready var screenSize : Vector2 = get_viewport_rect().size
@onready var zones : Array = $"../zones".get_children()
@onready var playerHand : PlayerHand = $"../PlayerHand"
@onready var inputManager : InputManager = $"../InputManager"
@onready var deck : Deck = $"../Deck"

var cardBeingDragged : Node = null
var isCardBeingHovered : bool = false

func _process(_delta : float) -> void:
	if cardBeingDragged:
		var mousePos : Vector2 = get_global_mouse_position()
		cardBeingDragged.position = Vector2(clamp(mousePos.x, 0, screenSize.x), clamp(mousePos.y, 0, screenSize.y))


func start_drag(card : Card) -> void:
	cardBeingDragged = card
	card.scaler.scale = Vector2.ONE


func finish_drag() -> void:
	if !cardBeingDragged: return

	cardBeingDragged.scaler.scale = HOVER_SCALE
	var zoneFound : Zone = inputManager.zone_check()
	if zoneFound && !zoneFound.has_card(): drop_in_zone(zoneFound)
	else: playerHand.add_card_to_hand(cardBeingDragged)
	cardBeingDragged = null


func drop_in_zone(zone : Zone) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(cardBeingDragged, "global_position", zone.global_position, 0.1)
	cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = true
	playerHand.remove_card_from_hand(cardBeingDragged)
	zone.card = cardBeingDragged
	zone.highlight_zone(false)


func get_top_card(cards : Array) -> Card:
	if cards.is_empty(): return null

	var highestCard : Card = cards[0].collider.get_parent()
	var highestZ : int = highestCard.z_index

	for i in range(1, cards.size()):
		var currentCard : Card = cards[i].collider.get_parent()
		if currentCard.z_index > highestZ:
			highestCard = currentCard
			highestZ = currentCard.z_index

	return highestCard


func connect_card_signals(card : Card) -> void:
	card.cardHovered.connect(_on_cardHovered.bind(card))
	card.cardUnHovered.connect(_on_cardUnHovered.bind(card))


func _on_cardHovered(card : Card) -> void:
	if !isCardBeingHovered:
		isCardBeingHovered = true
		highlight_card(card, true)


func _on_cardUnHovered(card : Card) -> void: 
	if !cardBeingDragged:
		highlight_card(card, false)
		isCardBeingHovered = false
		#var newCardHovered = card_check()
		#if newCardHovered: highlight_card(newCardHovered, true)
		#else: isCardBeingHovered = false


func highlight_card(card, hovered) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	if hovered:
		tween.tween_property(card.scaler, "scale", HOVER_SCALE, 0.1)
		card.z_index = 2
	else:
		tween.tween_property(card.scaler, "scale", Vector2.ONE, 0.1)
		card.z_index = 1


func _on_input_manager_leftbutton_released() -> void: finish_drag()


func _on_input_manager_leftbutton_clicked() -> void:
	pass # Replace with function body.
