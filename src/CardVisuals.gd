@tool
extends Control
class_name CardVisuals

# use this card to change any visual values, don't store any actual values here,
# this class is for visuals only.
var linkedCard : Card

#region Constants
const SKILL_COLOR : Color = Color("e44298")
const FSKILL_COLOR : Color = Color("16a98fff")
const KEYWORD_COLOR : Color = Color.ORANGE
#endregion

#region Onreadys
@onready var card_bg: TextureRect = %cardBG
@onready var art: TextureRect = %art
@onready var lvlText: Label = %lvl
@onready var cardname: RichTextLabel = %name
@onready var typeText: Label = %type
@onready var forceText: Label = %force
@onready var keywords: RichTextLabel = %keywords
@onready var passiveText: RichTextLabel = %passive
@onready var castText: RichTextLabel = %cast
@onready var skillText: RichTextLabel = %skill
#endregion

#region Text Parse Tags
var TEXT_TAGS : Dictionary = {
    "RITUAL:" : {},
    "HEAL:" : {},
    "FORCE" : {},
}

var KEYWORDS : Dictionary = {
    # positive keywords
    "QUICK" : {},
    "BLEED" : {},
    "IMMORTAL" : {},
    "SAFE" : {},

    # negative keywords
    "SICK" : {},
    "FRAGILE" : {},
    "STATIC" : {},
    "DELAYED" : {},
    "DOOM" : {},
    "MUTED" : {},
}

var TRIGGERS : Dictionary = {
    "END:" : {},
    "BEGIN:" : {},
    "VICTOR:" : {},
    "PERISH:" : {},
    "ENTER:" : {},
    "MOVE:" : {},
}
#endregion

#region Static Functions
static func func_to_small_caps(string : String, fontsize : int = 1) -> String:
    var words = string.strip_edges().to_upper().split(" ")
    var parts : Array = []
    for w in words:
        if w.length() <= 1:
            parts.append("[font_size=%d]%s[/font_size]" % [fontsize, w])
        else:
            var first = w[0]
            var rest = w.substr(1)
            parts.append("[font_size=%d]%s[/font_size][font_size=%d]%s[/font_size]" % [fontsize, first, floor(fontsize * 0.5), rest])
    return " ".join(parts)


static func parse_card_text(string : String) -> String:
    return string
#endregion

func _ready(): attempt_to_link()


# attemps to link to the parent card for visuals
func attempt_to_link() -> bool:
    if linkedCard: return true

    var potentialLinkedCard : Node = self
    while !linkedCard:
        potentialLinkedCard = potentialLinkedCard.get_parent()
        if potentialLinkedCard is Card:
            linkedCard = potentialLinkedCard
            return true
    return false


func connect_to_card(card : Card) -> void:
    if linkedCard: return
    linkedCard = card
    linkedCard.reset_stats()


func update_force() -> void:
    if !attempt_to_link(): return
    forceText.text = str(linkedCard.force)


func update_lvl() -> void:
    if !attempt_to_link(): return
    lvlText.text = str(linkedCard.LVL)


func update_type() -> void:
    if !attempt_to_link(): return
    for i : int in linkedCard.types.size():
        var type : String = linkedCard.types[i].capitalize()
        typeText.text += type + ("," if i+1 == linkedCard.types.size() else "")


func update_keywords() -> void:
    if !attempt_to_link(): return
    for i : int in linkedCard.keywords.size():
        var keyword : String = str(linkedCard.keywords[i]).capitalize()
        keywords.text += keyword + ("," if i+1 == linkedCard.keywords.size() else "")


func update_cast() -> void:
    if !attempt_to_link(): return


func update_skill() -> void:
    if !attempt_to_link(): return

