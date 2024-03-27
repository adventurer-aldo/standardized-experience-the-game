extends MarginContainer

signal parent_pressed(id)
signal delete_pressed(id)
signal edit_pressed(id)

var questions := []
var parenting = false
var resource: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	$Elements/Question.text = questions[0]
	$Elements/Level.text = ["1st Test", "2nd Test", "", "Exam"][resource.level - 1]
	Global.data_questions_edit_button_pressed.connect(_on_global_question_being_edited)
	# Global.data_questions_edit_button_pressed.connect(check_if_is_current_edited_question_parent)
	Global.data_questions_parent_was_deleted.connect(check_if_deleted_parent_is_self)

func check_if_was_edited_question(submitted_question):
	var matcher = submitted_question.id == resource.id
	print(matcher)
	if matcher:
		reload(submitted_question)

func reload(data: Resource):
	questions = data.question
	$Elements/Question.text = questions[0]
	$Elements/Level.text = ["1st Test", "2nd Test", "", "Exam"][data.level - 1]
	resource = data

func _on_global_question_being_edited(edited_question):
	if edited_question.parents.has(resource.id) && $Elements/Parent.button_pressed == false:
		_on_parent_pressed()
		$Elements/Parent.button_pressed = true
		print(edited_question.question[0])
	elif !edited_question.parents.has(resource.id) && $Elements/Parent.button_pressed == true:
		_on_parent_pressed()
		$Elements/Parent.button_pressed = false

func _on_parent_pressed():
	Global.emit_signal("data_questions_parent_button_pressed", resource.id)
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

func check_if_deleted_parent_is_self(parent_id: String):
	if int(parent_id) == resource.id:
		$Elements/Parent.button_pressed = false

func check_if_is_current_edited_question_parent(edited_question):
	if edited_question.parents.has(resource.id) && $Elements/Parent.button_pressed == false:
		$Elements/Parent._pressed()
	elif !edited_question.parents.has(resource.id) && $Elements/Parent.button_pressed == true:
		pass
