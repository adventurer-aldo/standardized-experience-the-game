extends Panel

@export var data_question_scene: PackedScene

@onready var title = $M/Elements/Quick/MTitle/M/Name/Title
@onready var description = $M/Elements/MTitle/VBoxContainer/Description
var subject_id: int

func set_title(to: String) -> void:
	$M/Elements/Quick/MTitle/M/Name/Title.text = to

func set_description(to: String) -> void:
	$M/Elements/MTitle/VBoxContainer/Description.text = to

func set_level(to: int) -> void:
	$M/Elements/Quick/Level.text = "Lv. " + str(to)

func set_questions_size(to: int) -> void:
	var res:= str(to) + " Question"
	if to != 1: res+= "s"
	$M/Elements/MTitle/VBoxContainer/Details/Questions.text = res

func _on_subject_pressed() -> void:
	var question_scene = data_question_scene.instantiate()
	question_scene.subject_id = subject_id
	question_scene.title = $M/Elements/Quick/MTitle/M/Name/Title.text
	add_child(question_scene)
