extends VBoxContainer

signal parent_pressed(id)

var id := 0
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


func _on_edit_pressed():
	emit_signal("parent_pressed", id)
	print("pressed from button")
