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
var resource: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	$Elements/Question.text = questions[0]
	$Elements/Level.text = ["1st Test", "2nd Test", "", "Exam"][level - 1]
	Global.data_questions_edit_button_pressed.connect(_on_global_question_being_edited)
	Global.data_questions_edit_button_pressed.connect(check_if_is_current_edited_question_parent)

func _on_global_question_being_edited(resource):
	if resource.parents.has(id) && $Elements/Parent.button_pressed == false:
		_on_parent_pressed()
		$Elements/Parent.button_pressed = true
	elif !resource.parents.has(id) && $Elements/Parent.button_pressed == true:
		_on_parent_pressed()

func _on_parent_pressed():
	Global.emit_signal("data_questions_parent_button_pressed", id)
	if $Elements/Parent.button_pressed:
		add_to_group("parenting")
	else:
		remove_from_group("parenting")

func change_parenting():
	$Elements/Parent.button_pressed = false if $Elements/Parent.button_pressed == true else true

func _on_delete_pressed():
	Global.emit_signal("data_questions_delete_button_pressed", resource)
	queue_free()

func _on_edit_pressed():
	Global.emit_signal("data_questions_edit_button_pressed", resource)

func check_if_is_current_edited_question_parent(edited_question):
	if edited_question.id == resource.id: 
		$Elements/Parent.button_pressed = true
	elif $Elements/Parent.button_pressed == true:
		$Elements/Parent.button_pressed = false
