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
@export var answer = [[""]]
@export var choices = {}
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
@export var learn_level: int
@export var experience: float = 0.0
@export var is_level_up_queued: int
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

func save_to_quiz(quiz_id: int):
	var quiz_id_dir = str(quiz_id).lpad(10, '0') + '/'
	var id_filename = str(id).lpad(10, '0') + '.tres'
	ResourceSaver.save(self, "user://quizzes/" + quiz_id_dir + id_filename, ResourceSaver.FLAG_COMPRESS)
