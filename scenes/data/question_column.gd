extends MarginContainer

signal parent_pressed(id)
signal delete_pressed(id)
signal edit_pressed(id)

var id := 0
var level := 1
var questions := []
var types := []
var tags : PackedStringArray = PackedStringArray([])
var parenting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Elements/Question.text = questions[0]
	$Elements/Level.text = ["1st Test", "2nd Test", "", "Exam"][level - 1]


func _on_parent_pressed():
	emit_signal("parent_pressed", id)
	if $Elements/Parent.button_pressed:
		add_to_group("parenting")
	else:
		remove_from_group("parenting")

func change_parenting():
	$Elements/Parent.button_pressed = false if $Elements/Parent.button_pressed == true else true

func _on_delete_pressed():
	emit_signal("delete_pressed", id)
	queue_free()
