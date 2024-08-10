extends Control

@export var question_scene: PackedScene
@export var subject_id: int

func _ready() -> void:
	#return
	for question in Global.get_subject(subject_id).get_questions():
		var new_question = question_scene.instantiate()
		new_question.question = question.question[0]
		new_question.level = question.level
		new_question.spaced_level = question.spaced_level
		$QuestionsPart/Scroller/GridContainer.add_child(new_question)
