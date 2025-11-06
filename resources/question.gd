@tool
class_name Question
extends Resource

@export_category('Identifiers')
@export var id: int
@export var subject_id: int
@export var created_at: int
@export var last_time_edited: int
@export var tags:= []

@export_category('Sensory Add-Ons')
@export var media: Array
@export var sounds: Array[AudioStream]

@export_category('Data')
@export var question: PackedStringArray = []
@export var answer = [{"texts": [""]}]
@export var choices:= []
@export var columns = {}
@export var match_a = {}
@export var match_b = {}
@export var labels:= []
@export var variables = []

@export var level: int = 1

@export_category('Question Types')
@export var is_open: bool = false
@export var is_choice: bool = false
@export var is_table: bool = false
@export var is_label: bool = false
@export var is_connect: bool = false

@export_category('Question Add-Ons')
@export var is_order: bool = false
@export var is_strict: bool = false
@export var is_gap: bool = false
@export var is_veracity: bool = false
@export var is_shuffle: bool = false

@export_category('Experience')
@export var parents := []
@export var experience_level:= 1
@export var experience: float = 0.0
@export var is_level_up_queued: bool
@export_group("Streaks")
@export var hits: int
@export var misses: int
@export var hit_streak: int
@export var miss_streak: int

@export_category("Quiz Answer")
@export var attempt := []
@export var formulated_variables := []
@export var attempt_type: String

func get_types() -> Array:
	var types = []
	if is_open: types.push_back('open')
	if is_choice: types.push_back('choice')
	if is_table: types.push_back('table')
	if is_label: types.push_back('label')
	if is_connect: types.push_back('connect')
	return types

func get_parameters() -> Array:
	var parameters = []
	if is_strict: parameters.push_back('strict')
	if is_shuffle: parameters.push_back('shuffle')
	if is_order: parameters.push_back('order')
	return parameters

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func create() -> void:
	id = Main.data.next_question_id(true)
	save()

func save() -> void:
	var subject_id_dir = str(subject_id).lpad(10, '0') + '/'
	var id_filename = str(id).lpad(10, '0') + '.tres'
	ResourceSaver.save(self, "user://subjects/" + subject_id_dir + id_filename, ResourceSaver.FLAG_COMPRESS)

func save_to_quiz(quiz_id: int, attempt_id:= id):
	var quiz_id_dir = str(quiz_id).lpad(10, '0') + '/'
	var id_filename = str(attempt_id).lpad(10, '0') + '.tres'
	ResourceSaver.save(self, "user://quizzes/" + quiz_id_dir + id_filename, ResourceSaver.FLAG_COMPRESS)

# ==============================================================================
# LEVELING
# ==============================================================================
func hit() -> void:
	hits += 1
	hit_streak += 1
	miss_streak = 0
	if hit_streak > 1 && !is_level_up_queued:
		var next_level = experience_level + 1
		hit_streak = 0
		experience_level = clampi(next_level, 1, 15)
		queue_level_up(next_level)
	save()

func miss() -> void:
	misses += 1
	miss_streak += 1
	hit_streak = 0
	if miss_streak > 1 && !is_level_up_queued:
		miss_streak = 0
		experience_level = clampi(experience_level - 1, 1, 15)
	save()

func queue_level_up(to_level: int) -> void:
	is_level_up_queued = true
	var due_time:= 0.0
	match to_level:
		2: due_time = 10 * 60
		3: due_time = 1 * 60 * 60
		4: due_time = 8 * 60 * 60
		5: due_time = 24 * 60 * 60
		6: due_time = 3 * 24 * 60 * 60
		7: due_time = 6 * 24 * 60 * 60
		8: due_time = 12 * 24 * 60 * 60
		9: due_time = 19 * 24 * 60 * 60
		10: due_time = 31 * 24 * 60 * 60
		11: due_time = 62 * 24 * 60 * 60
		12: due_time = 124 * 24 * 60 * 60
		13: due_time = 248 * 24 * 60 * 60
		14: due_time = 365 * 24 * 60 * 60

	var level_queue = LevelingQueue.new()
	level_queue.id = Main.data.next_leveling_queue_id()
	level_queue.subject_id = subject_id
	level_queue.question_id = id
	level_queue.due_time = due_time + Time.get_unix_time_from_system()
	level_queue.save()
# ==============================================================================
# OTHERS
# ==============================================================================
func are_parents_decent() -> bool:
	var subject = get_subject()
	var verdicts:= parents.map(func (parent_id):
		var parent = subject.get_question(parent_id)
		return parent.experience_level > 3 || parent.is_level_up_queued
	)
	return !verdicts.has(false)
