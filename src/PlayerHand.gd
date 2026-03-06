extends Node2D
class_name PlayerHand

const CARD_WIDTH = 128
const HAND_Y_POS = 1050
const DEFAULT_SPEED : float = 0.1

@onready var cardManager : CardManager = $"../CardManager"
@onready var centerScreen_x : float = get_viewport_rect().size.x / 2

var hand : Array[Card] = []

func add_card_to_hand(card : Card, speed : float = DEFAULT_SPEED) -> void:
    if !card in hand: 
        hand.insert(0, card)
        update_hand_positions(speed)
    else:
        animate_card_to_position(card, card.handPos, speed)


func update_hand_positions(speed : float = DEFAULT_SPEED) -> void:
    for i in hand.size():
        var newPos : Vector2 = Vector2(calculate_card_position(i), HAND_Y_POS)
        var card : Card = hand[i]
        card.handPos = newPos
        animate_card_to_position(card, newPos, speed)


func calculate_card_position(IDX : int) -> float:
    var totalWidth : float = (hand.size() - 1) * CARD_WIDTH
    var x_offset : float = centerScreen_x + IDX * CARD_WIDTH - totalWidth / 2
    return x_offset


func animate_card_to_position(card : Card, pos : Vector2, speed : float = DEFAULT_SPEED) -> void:
    var tween := create_tween().set_trans(Tween.TRANS_SINE)
    tween.tween_property(card, "global_position", pos, speed)


func remove_card_from_hand(card : Card) -> void:
    if card in hand:
        hand.erase(card)
        update_hand_positions()