@tool
@icon("uid://b0psj1ihvfcu6")
extends Control
class_name PectoCard

const TEMPLATE_SCENE : String = "res://scenes/cardTemplates/card_visuals.tscn"

#region Data
var db : Dictionary
var data : Dictionary

@export_group("Data")
@export var ID : String = "" ## reference to the database's card ID for retrieving data
@export_tool_button("Update Card")
var updateButton = func():
	PectoCard.get_card_data(self)
	update_card_data(true)

@export_tool_button("Reset Card")
var resetButton = reset_card_data

var isToken : bool = false
enum RARITY{Basic, Rare, Superrare, Divinerare}
enum ACTIVATION_TYPE{None, Skill, Spell, Reusable, Assist}

#endregion

#region Visual
var cardVisuals : CardVisuals

@export_group("info")
@export var cardName : String = "Abstract Wizard" :
	set(val):
		cardName = val
		update_card_visuals()

@export var force : int = 1 :
	set(val):
		force = val
		update_card_visuals()

@export_range(0, 99) var lvl : int = 1 :
	set(val):
		lvl = clamp(val, 0, 99)
		update_card_visuals()

@export var types : Array[String] :
	set(val):
		types = val
		update_card_visuals()

@export var keywords : Array[String] = [] :
	set(val):
		for k : String in val: k = k.to_lower()
		keywords = val
		update_card_visuals()
		
@export_multiline var text : String = "Dummy text goes here!" :
	set(val):
		text = val
		update_card_visuals()
		
@export_multiline var activationText : String = "Dummy text goes here!" :
	set(val):
		activationText = val
		update_card_visuals()
			
@export_group("visual")
@export var art : Texture:
	set(val):
		art = val
		update_card_visuals()
			
@export var foil : bool = false:
	set(val):
		foil = val
		update_card_visuals()

@export var rarity : RARITY = RARITY.Basic:
	set(val):
		rarity = val
		update_card_visuals()

#endregion

#region Logic
@export_group("Logic")
@export var cardLogicNode : Node
@export var skill : Node

signal enter(card : PectoCard)
signal victor(card : PectoCard, target : Node)
signal perish(card : PectoCard, condition : String)
signal activeStatusChanged(status : bool)

var inPlay : bool = false
var isReady : bool = true :
	set(val):
		if val != isReady:
			isReady = val
			activeStatusChanged.emit(isReady)

func _ready():
	custom_minimum_size = Vector2(750, 1050)
	PectoCard.get_card_data(self)
	update_card_data(Engine.is_editor_hint())
	spawn_card_template()


func spawn_card_template() -> void:
	for n in get_children():
		if n is CardVisuals:
			n.queue_free()
			break
	cardVisuals = load(TEMPLATE_SCENE).instantiate()
	add_child(cardVisuals)
	update_card_visuals()


func _enter() -> void:
	inPlay = true
	enter.emit(self)
	
	if keywords.has("delayed"): isReady = false
	else: isReady = true


func _perish(condition : String) -> void:
	perish.emit(self, condition)
	_exit()


func _exit() -> void:
	inPlay = false


func _victor(target : Node) -> void:
	victor.emit(self, target)


func attack_card(target : Node) -> void:
	if target is PectoBoard3D:
		if target.has_method("deal_damage"):
			target.deal_damage(force)
			return attack_aftermath(target)

	var target_startForce : int = target.force
	var self_startForce : int = force

	# this card attacks target
	if !has_keyword("bleed"): target.deal_damage(self_startForce)
	else: target.force = 0

	# target deals damage back
	if !has_keyword("quick") || target.force > 0:
		if !target.has_bleed(): deal_damage(target_startForce)
		else: force = 0

	attack_aftermath(target)


func attack_aftermath(target : Node) -> void:
	if has_keyword("fragile"): force = 0
	else: _victor(target)

	if target is PectoCard:
		if target.force > 0:
			if target.has_keyword("fragile"): target.force = 0
			else: target._victor(self)


func deal_damage(amount : int) -> void: force -= amount
func heal_damage(amount : int) -> void: force += amount
func has_keyword(key : String) -> bool: return keywords.has(key.to_lower())


func acquire_target(amount : int, targettablePlayers = ["self", "opponent"],
	filter : Array = ["u", "i", "s", "t", "p"], minimum = -1, allTarget : bool = false, ) -> Array:
	var possibleTargets : Array = []
	var selfTargets : Array = GameManager.playerBoards[0].get_controlled_cards() if targettablePlayers.has("self") else []
	var opponentTargets : Array = GameManager.playerBoards[1].get_controlled_cards() if targettablePlayers.has("opponent") else []

	possibleTargets = selfTargets + opponentTargets

	# filter out cards that can't be targetted
	for card3D : PectoCard3D in possibleTargets:
		match card3D.card.types:
			0: if !filter.has("u"): possibleTargets.erase(card3D)
			1: if !filter.has("i"): possibleTargets.erase(card3D)
			2: if !filter.has("s"): possibleTargets.erase(card3D)
			3: if !filter.has("t"): possibleTargets.erase(card3D)

	# add players as targets if possible
	if filter.has("p"):
		possibleTargets.append(GameManager.playerBoards[0] if targettablePlayers.has("self") else null)
		possibleTargets.append(GameManager.playerBoards[1] if targettablePlayers.has("self") else null)

	# don't ask for targets if it should target all possible targets
	if allTarget: return possibleTargets
	return await GameManager.gameScene.select_targets(
		get_physical_card().controller, possibleTargets, amount, minimum)

#endregion

#region functions
static func get_card_data(card : PectoCard) -> Dictionary:
	var retrieved : Dictionary = {}
	var msg : String = ""
	card.db = {}

	if card.ID == "": 
		msg = "Card ID is invalid!"
	else:
		if Engine.is_editor_hint():
			var DB_PATH : String = "res://data/pectoDB.json"
			if FileAccess.file_exists(GameManager.DB_PATH):
				var file : FileAccess = FileAccess.open(DB_PATH, FileAccess.READ)
				card.db = JSON.parse_string(file.get_as_text())
			else:
				printerr("File Doesn't Exist!")
		else:
			card.db = GameManager.DB

		# data has been found, see if the card exists in it
		if card.db:
			if card.db["cards"].keys().has(card.ID):
				retrieved = card.db["cards"][card.ID]
				msg = "Data retrieved successfully!"
	print(msg)
	print(retrieved)
	card.data = retrieved
	return card.data


func update_card_data(_updateScenePath : bool = false) -> void:
	cardName = data["name"]
	types = data["types"]

	lvl = data["lvl"]
	force = data["force"]

	keywords = data["keywords"]
	text = data["text"]

	if data["skill"]:
		var skillData : Dictionary = db["skills"][data["skill"]]
		activationText = skillData["text"]

	if FileAccess.file_exists("res://assets/set1/" + data["art"]):
		art = load("res://assets/set1/" + data["art"])


func reset_card_data() -> void:
	ID = ""
	cardName = "Dummy"
	types = []
	lvl = 0
	force = 1
	keywords = []
	text = "insert dummy text here!"
	activationText = ""
	art = null


func update_card_visuals() -> void:
	var visuals : CardVisuals = cardVisuals
	if !visuals: return
	
	visuals.cardName = cardName

	visuals.force = force
	visuals.lvl = lvl

	visuals.types = types
	visuals.keywords = keywords
	visuals.text = text

	visuals.activationText = activationText

	visuals.art = art
	visuals.show()

#endregion


#region setters
func set_force(newForce : int = 1) -> void: force = newForce
func change_force(amount : int = 1) -> void: force += amount
func set_lvl(newLVL : int = 1) -> void: lvl = newLVL
func change_lvl(amount : int = 1) -> void: lvl += amount
#endregion

#region getters
func get_card_text() -> String: return cardVisuals.get_card_text()
func get_card_keyword_text() -> String: return cardVisuals.get_card_keyword_text()
func get_card_skill() -> String: return cardVisuals.get_card_skill()
func get_card_name() -> String: return cardVisuals.get_card_name()
func get_card_art() -> Texture: return cardVisuals.get_card_art()
func get_card_types() -> PackedStringArray: return cardVisuals.get_card_types()
func get_physical_card() -> PectoCard3D: return get_parent().get_parent()
#endregion
