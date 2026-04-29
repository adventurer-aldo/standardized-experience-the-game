@tool
extends Resource
class_name Chair

enum GradeSlot { FIRST = 1, SECOND = 2, DISSERTATION = 3, REPOSITION = 4, EXAM = 5, RECURRENCE = 6 }
enum AverageFormula { TESTS_ONLY, TESTS_80_DISSERTATION_20 }
enum Status { IN_PROGRESS, EXEMPTED, EXAM_ELIGIBLE, FAILED_AVERAGE, PASSED_EXAM, RECURRENCE_ELIGIBLE, PASSED_RECURRENCE, FAILED_RECURRENCE }
enum Diagnosis { PERFECT, PASSED, EXAM_READY, DANGER, FAILED, INCOMPLETE }

const PASS_GRADE := 9.5
const EXEMPTION_GRADE := 14.5
const PERFECT_GRADE := 19.9

@export_category("Identification")
@export var id: int
@export var subject_id: int
@export var journey_id: int

@export_category("Rules")
@export var average_formula:= AverageFormula.TESTS_ONLY

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
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, "0") + ".tres")


func get_journey() -> Journey:
	return ResourceLoader.load("user://journeys/" + str(journey_id).lpad(10, "0") + ".tres")


func get_file_path() -> String:
	return "user://journeys/" + str(journey_id).lpad(10, "0") + "/" + str(id).lpad(10, "0") + ".tres"


func set_grade(slot: int, grade: float, quiz_id:= 0) -> void:
	grade = clampf(grade, 0.0, 20.0)
	match slot:
		GradeSlot.FIRST:
			first = grade
			first_quiz_id = quiz_id
		GradeSlot.SECOND:
			second = grade
			second_quiz_id = quiz_id
		GradeSlot.DISSERTATION:
			dissertation = grade
			dissertation_quiz_id = quiz_id
		GradeSlot.REPOSITION:
			reposition = grade
			reposition_quiz_id = quiz_id
		GradeSlot.EXAM:
			exam = grade
			exam_quiz_id = quiz_id
		GradeSlot.RECURRENCE:
			recurrence = grade
			recurrence_quiz_id = quiz_id
	save()


func set_grade_from_quiz(slot: int, quiz: Quiz, uses_negative_points:= false) -> void:
	set_grade(slot, quiz.calculate_grade(uses_negative_points), quiz.id)


func has_grade(grade: float) -> bool:
	return grade >= 0.0


func get_first_second_average() -> float:
	if has_grade(first) && has_grade(second):
		return (first + second) / 2.0
	if has_grade(reposition):
		if has_grade(first):
			return (first + reposition) / 2.0
		if has_grade(second):
			return (reposition + second) / 2.0
		return reposition
	if has_grade(first):
		return first
	if has_grade(second):
		return second
	return -1.0


func ensure_dissertation_grade() -> void:
	var subject = get_subject()
	if has_grade(dissertation) || subject == null || subject.has_questions_at_level(3):
		return
	dissertation = randf_range(9.5, 17.5)
	save()


func get_average() -> float:
	ensure_dissertation_grade()
	var tests_average = get_first_second_average()
	if !has_grade(tests_average):
		return -1.0
	match average_formula:
		AverageFormula.TESTS_80_DISSERTATION_20:
			if has_grade(dissertation):
				return tests_average * 0.8 + dissertation * 0.2
	return tests_average


func can_take_reposition() -> bool:
	return !(has_grade(first) && has_grade(second))


func can_take_exam() -> bool:
	var subject = get_subject()
	var average = get_average()
	if !has_grade(average):
		return false
	if subject != null && subject.exemption && average >= EXEMPTION_GRADE:
		return false
	var minimum_exam_access = EXEMPTION_GRADE if subject != null && subject.rigid else PASS_GRADE
	return average >= minimum_exam_access


func can_take_recurrence() -> bool:
	return has_grade(exam) && exam < PASS_GRADE && !has_grade(recurrence)


func has_passed() -> bool:
	var subject = get_subject()
	var average = get_average()
	if subject != null && subject.exemption && average >= EXEMPTION_GRADE:
		return true
	return exam >= PASS_GRADE || recurrence >= PASS_GRADE


func has_failed() -> bool:
	var average = get_average()
	if !has_grade(average):
		return false
	if has_passed():
		return false
	if !can_take_exam() && !has_grade(exam):
		return true
	return has_grade(recurrence) && recurrence < PASS_GRADE


func get_status() -> int:
	var subject = get_subject()
	var average = get_average()
	if subject != null && subject.exemption && average >= EXEMPTION_GRADE:
		return Status.EXEMPTED
	if exam >= PASS_GRADE:
		return Status.PASSED_EXAM
	if recurrence >= PASS_GRADE:
		return Status.PASSED_RECURRENCE
	if has_grade(recurrence) && recurrence < PASS_GRADE:
		return Status.FAILED_RECURRENCE
	if has_grade(exam) && exam < PASS_GRADE:
		return Status.RECURRENCE_ELIGIBLE
	if can_take_exam():
		return Status.EXAM_ELIGIBLE
	if has_grade(average):
		return Status.FAILED_AVERAGE
	return Status.IN_PROGRESS


func get_diagnosis() -> int:
	if has_passed():
		var final_grade = get_final_grade()
		if final_grade >= PERFECT_GRADE:
			return Diagnosis.PERFECT
		return Diagnosis.PASSED
	if can_take_exam():
		return Diagnosis.EXAM_READY
	if has_failed():
		return Diagnosis.FAILED
	if has_grade(get_average()):
		return Diagnosis.DANGER
	return Diagnosis.INCOMPLETE


func get_final_grade() -> float:
	var average = get_average()
	if recurrence >= PASS_GRADE:
		return recurrence
	if exam >= PASS_GRADE:
		return exam
	return average


func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
