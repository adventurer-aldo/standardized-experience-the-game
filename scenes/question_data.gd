extends VBoxContainer

var level := 1
var questions := []
var types := []
var tags : PackedStringArray = PackedStringArray([])

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/Margin/Horizontal/Level.text = "Lv. " + str(level)
	$Backgrounder/MarginContainer/VBoxContainer/Question.text = questions[0]
	$BackgrounderTags/MarginContainer/Tags.text = ", ".join(tags)
	if types.has("open"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Open.show()
	if types.has("choice"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Choice.show()
	if types.has("veracity"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Veracity.show()
	if types.has("match"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Match.show()
	if types.has("fill"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Fill.show()
	if types.has("table"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Table.show()
	if types.has("strict"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Strict.show()
	if types.has("order"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Order.show()
	if types.has("shuffle"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Shuffle.show()
	if types.has("enumerate"): $Backgrounder/MarginContainer/VBoxContainer/TypesContainer/Enumerate.show()
