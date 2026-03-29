@tool
extends Resource
class_name Chair

@export_category("Identification")
@export var id: int
@export var subject_id: int
@export var journey_id: int

@export_category("Grading")
@export var first: float = -1.0
@export var first_quiz_id: int
@export var second: float = -1.0
@export var second_quiz_id: int
@export var reposition: float = -1.0
@export var reposition_quiz_id: int
@export var dissertation: float = -1.0
@export var dissertation_quiz_id: int
@export var exam: float = -1.0
@export var exam_quiz_id: int
@export var recurrence: float = -1.0
@export var recurrence_quiz_id: int

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + '.tres')

func get_journey() -> Journey:
	return ResourceLoader.load("user://journeys/" + str(journey_id).lpad(10, '0') + '.tres')

func get_first_second_average() -> float:
	return (first + second) / 2.0

func save() -> void:
	var addendum = str(journey_id).lpad(10, '0') + "/" + str(id).lpad(10, '0')  + '.tres'
	ResourceSaver.save(self, "user://journeys/" + addendum)
