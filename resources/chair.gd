@tool
extends Resource
class_name Chair

@export_category("Identification")
@export var id: int
@export var subject_id: int
@export var journey_id: int

@export_category("Grading")
@export var first: float
@export var first_quiz_id: int
@export var second: float
@export var second_quiz_id: int
@export var reposition: float
@export var reposition_quiz_id: int
@export var dissertation: float
@export var dissertation_quiz_id: int
@export var exam: float
@export var exam_quiz_id: int
@export var recurrence: float
@export var recurrence_quiz_id: int

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + '.tres')

func get_journey() -> Journey:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + '.tres')

func get_first_second_average() -> float:
	return (first + second) / 2.0
