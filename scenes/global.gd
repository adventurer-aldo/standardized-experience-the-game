extends Node

signal finished
signal subjects_loaded
signal data_questions_edit_button_pressed(resource: Resource)
signal data_questions_parent_button_pressed(id: int)
signal data_questions_delete_button_pressed(resource: Resource)
signal data_questions_is_editing_question(id: int)
signal data_questions_parent_was_deleted(id: String)
signal data_questions_question_was_submitted(resource: Resource)

var subjects := {}
var questions := {}
var quiz
var redo = 0
var stats: Stats

func _ready():
	for dir in ["subjects", "quizzes", "journeys", "queues"]:
		if !DirAccess.dir_exists_absolute("user://{dir}".format({"dir": dir})):
			DirAccess.make_dir_absolute("user://{dir}".format({"dir": dir}))
	if ResourceLoader.exists("user://stats.res"):
		stats = ResourceLoader.load("user://stats.res")
	else:
		stats = load("res://resources/stats.tres").duplicate()
		ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)


func save_stats():
	ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)

func get_subject(id: int) -> Subject:
	return subjects[id]

func get_question(_subject_id: int, _question_id: int) -> Question:
	return

func get_quiz(id: int) -> Quiz:
	return ResourceLoader.load("user://quizzes/" + str(id) + '.res')

func get_last_quiz() -> Quiz:
	return get_quiz(stats.last_quiz_id)

func get_formatted_grade(grade: float):
	return String.num(grade, 2).replace(".", ",")

func generate_random_color_with_contrast():
	var random_color = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))

	# Calculate the luminance of the color
	var luminance = 0.2126 * random_color.r + 0.7152 * random_color.g + 0.0722 * random_color.b

	# Check if the luminance is too bright or too dark
	if luminance > 0.5:
		# If too bright, make the color darker
		random_color.r = random_color.r * 0.7
		random_color.g = random_color.g * 0.7
		random_color.b = random_color.b * 0.7
	else:
		pass
		# If too dark, make the color lighter
		# random_color.r = random_color.r + (1 - random_color.r) * 0.3
		# random_color.g = random_color.g + (1 - random_color.g) * 0.3
		# random_color.b = random_color.b + (1 - random_color.b) * 0.3

	return random_color
