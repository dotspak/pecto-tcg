extends Node2D
class_name Deck

const CARD_SCENE_PATH : String = "res://scenes/card.tscn"
const CARD_DRAW_SPEED : float = 0.2

var deck : Array[String] = ["crow", "crow", "crow"]

@onready var cardManager : CardManager = $"../CardManager"
@onready var playerHand : PlayerHand = $"../PlayerHand"

func draw_card() -> void:
    var cardDrawn : String = deck[0]
    deck.erase(cardDrawn)

    if deck.is_empty():
        $Area2D/CollisionShape2D.disabled = true
        $Sprite2D.hide()

    var cardScene : PackedScene = preload(CARD_SCENE_PATH)
    var newCard : Card = cardScene.instantiate()
    cardManager.add_child(newCard)

    newCard.global_position = global_position
    newCard.name = cardDrawn
    playerHand.add_card_to_hand(newCard, CARD_DRAW_SPEED)
        