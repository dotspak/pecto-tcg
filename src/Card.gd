@tool
extends Node2D
class_name Card

enum KEYWORDS{
    # positive
    QUICK, BLEED, IMMORTAL, SAFE, 

    # negative
    SICK, FRAGILE, STATIC, DELAYED, DOOM, MUTED
    }

@export var cardName : String = "Card Name"
@export var baseForce : int = 0
@export var baseLVL : int = 1
@export var baseKeywords : Array[KEYWORDS] = []
@export var baseTypes : Array[String] = []

var force : int = 0
var LVL : int = 0
var keywords : Array[KEYWORDS] = []
var types : Array[String] = []

func _ready(): 
    get_parent().connect_card_signals(self)
    reset_stats()

func reset_stats() -> void:
    force = baseForce
    LVL = baseLVL
    keywords = baseKeywords
    types = baseTypes

func enter_play() -> void:
    reset_stats()


func exit_play() -> void:
    reset_stats()


signal cardHovered
signal cardUnHovered

@onready var scaler : Node2D = $scaler

var handPos : Vector2 = Vector2.ZERO

func _on_area_2d_mouse_exited() -> void: cardUnHovered.emit()
func _on_area_2d_mouse_entered() -> void: cardHovered.emit()