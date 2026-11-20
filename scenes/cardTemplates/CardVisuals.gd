@tool
extends Control
class_name CardVisuals

const TEXT_SIZE : int = 24

# rarity icons
const BASIC_ICON : Texture = preload("uid://dmhctqok0ncxr")
const RARE_ICON : Texture = preload("uid://db7a3ny4orsly")
const SUPERRARE_ICON : Texture = preload("uid://b7pbscney3tcv")
const DIVINERARE_ICON : Texture = preload("uid://d1kafd45aa4e")

const FORCE_ICON_PATH: String = "res://assets/forceicon4.png"
const PASSIVE_ICON_PATH: String = "res://assets/passiveIcon.png"

const SKILL_COLOR : Color = Color("e44298")
const FSKILL_COLOR : Color = Color("16a98fff")

const KEYWORD_COLOR : Color = Color.ORANGE

# Activation labels
const LABEL_SKILL : String = "[color=#ffe4a8]★S[font_size=18]KILL [i](You may expend this ready card to activate this effect.)"
const LABEL_SPELL : String = "[color=#c7c8ff]↯S[font_size=18]PELL [i](Discard this card from play at any time to activate this effect.)"
const LABEL_REUSE : String = "[color=#f8d1ff]🗘R[font_size=18]EUSABLE [i](You may activate this effect if this card is ready.)"
const LABEL_ASSIST : String = "[color=#ffe1e1]❤A[font_size=18]SSIST [i](Only activate this effect when expending this card to play a card.)"
	
var TEXT_TAGS : Dictionary = {
	"trigger": {"color" : "orange", "icon" : "➥"},
	"force" : {"color" : "e44298", "icon" : ""},
	"key" : {"color" : KEYWORD_COLOR.to_html(), "icon" : ""}}

#region Variables

var cardName : String = "Dummy" :
	set(val):
		cardName = val
		if is_node_ready():
			%cardName.text = to_small_caps(cardName, 48, 32)
			%cardName.text.strip_edges()

var types : Array[String] :
	set(val):
		types = val
		if is_node_ready():
			update_type_label()

var force : int = 1 :
	set(val):
		force = val
		if is_node_ready():
			%cardForce.text = str(force)
		
var lvl : int = 1 :
	set(val):
		lvl = clamp(val, 0, 99)
		if is_node_ready():
			%cardLVL.text = str(lvl)

var keywords : Array[String] = [] :
	set(val):
		keywords = val
		if is_node_ready():
			format_keywords_list()
		
var text : String = "Dummy text goes here!" :
	set(val):
		text = val
		if is_node_ready():
			var parsed : String = parse_card_text(text)
			%cardText.text = parsed
			%textContainer.visible = parsed != ""

var activationText : String = "Dummy text goes here!" :
	set(val):
		activationText = val
		if is_node_ready():
			update_skill_box()
			
var art : Texture:
	set(val):
		art = val
		if is_node_ready():
			%cardArt.texture = art
			
var foil : bool = false:
	set(val):
		foil = val
		if is_node_ready():
			var m : ShaderMaterial = %cardArt.material
			m.set_shader_parameter("intensity", 0.4 if foil else 0.0)

var rarity : PectoCard.RARITY = PectoCard.RARITY.Basic:
	set(val):
		rarity = val
		if is_node_ready():
			var texture : Texture
			match rarity:
				PectoCard.RARITY.Basic: texture = BASIC_ICON
				PectoCard.RARITY.Rare: texture = RARE_ICON
				PectoCard.RARITY.Superrare: texture = SUPERRARE_ICON
				PectoCard.RARITY.Divinerare: texture = DIVINERARE_ICON
			%rarity.texture = texture

#endregion

#region Functions

func update_type_label() -> void:
	if !is_node_ready(): return
	var typeText : String = ""
	var t : Array[String] = types.duplicate(true)
	while !t.is_empty():
		var s : String = t.pop_front()
		typeText += s.capitalize()
		if !t.is_empty(): typeText += "/"

	%cardType.text = typeText
	%cardType.text.strip_edges()
	%cardType.visible = %cardType.text != ""


func update_skill_box() -> void:
	%skillContainer.hide()
	%cardSkill.text = ""

	var activation_regex := RegEx.new()
	activation_regex.compile(r"^\s*([A-Z]+):[ \t]*")

	var header := activation_regex.search(activationText)
	if header == null: return

	match header.get_string(1):
		"SKILL": %activationLabel.text = LABEL_SKILL
		"SPELL": %activationLabel.text = LABEL_SPELL
		"REUSE": %activationLabel.text = LABEL_REUSE
		"ASSIST": %activationLabel.text = LABEL_ASSIST
		_: return

	var effect_text := activationText.substr(header.get_end())
	%cardSkill.text = parse_card_text(effect_text)
	%skillContainer.show()


func parse_card_text(string: String) -> String:
	var trailingBraces := RegEx.new()
	trailingBraces.compile(r"(?m)\}+(?=[ \t\r]*$)")
	
	var output: String = trailingBraces.sub(string, "", true)
	var regex := RegEx.new()
	# Match stat labels even when attached to a number, like +1FORCE.
	regex.compile(r"(?<![A-Za-z_])(FORCE|NULL)\b|\b([A-Z]{2,})\b(:)?")

	var matches: Array[RegExMatch] = regex.search_all(output)
	for i: int in range(matches.size() - 1, -1, -1):
		var token: RegExMatch = matches[i]
		var stat: String = token.get_string(1)
		var label: String = token.get_string(2)
		var replacement: String

		# stat icon rendering
		if not stat.is_empty():
			var icon_path: String = FORCE_ICON_PATH if stat == "FORCE" else PASSIVE_ICON_PATH
			replacement = "[img=24]%s[/img]" % icon_path
		
		# ritual + triggers rendering
		elif token.get_string(3) == ":":
			if label == "RITUAL": replacement = format_ritual()
			else: replacement = format_trigger(label)
		
		# keyword rendering
		else: replacement = format_keyword(label)

		output = output.substr(0, token.get_start()) + replacement + output.substr(token.get_end())
	return output.strip_edges()


func to_small_caps(string : String, bigSize : int = TEXT_SIZE, smallSize : int = TEXT_SIZE - 8) -> String:
	var words = string.strip_edges().to_upper().split(" ")
	var parts : Array = []
	for w in words:
		if w.length() <= 1:
			parts.append("[font_size=%d]%s[/font_size]" % [bigSize, w])
		else:
			var first = w[0]
			var rest = w.substr(1)
			parts.append("[font_size=%d]%s[/font_size][font_size=%d]%s[/font_size]" % [bigSize, first, smallSize, rest])
	return " ".join(parts)

func format_keyword(keyword : String) -> String: return "[bgcolor=#00000088][color=%s][i]%s[/i][/color][/bgcolor]" % [KEYWORD_COLOR.to_html(), keyword.capitalize()]
func format_trigger(trigger : String) -> String: return "[bgcolor=orange][b]➥%s[/b][/bgcolor]" % to_small_caps(trigger.to_upper() + ":")
func format_ritual() -> String: return "[bgcolor=#ff0000][b]💀%s[/b][/bgcolor]" % to_small_caps("RITUAL:")

func format_keywords_list() -> void:
	%cardKeywords.text = ""
	var keys : Array[String] = keywords.duplicate(true)
	while !keys.is_empty():
		var k : String = format_keyword(keys.pop_front())
		%cardKeywords.text += k
		if !keys.is_empty(): %cardKeywords.text += ", "

	%cardKeywords.text.strip_edges()

#endregion

#region getters
func get_card_text() -> String: return %cardText.text
func get_card_keyword_text() -> String: return %cardKeywords.text.strip_edges()
func get_card_skill() -> String: return %cardSkill.text if true else ""
func get_card_name() -> String: 
	return parse_card_text(
		%cardName.text + " " + "{force:%s}" % force + "/" 
		+ "[color=%s]LVL: %s" % [Color.WHITE.to_html(), lvl])
func get_card_art() -> Texture: return art
func get_card_types() -> PackedStringArray: 
	var t : String = %cardType.text.to_lower()
	var r : RegEx = RegEx.new()
	r.compile("[^a-zA-Z]+")
	t = r.sub(t, " ", true)
	return t.split(" ", false)
#endregion