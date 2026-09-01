@tool
class_name Question
extends Resource

@export_category('Identifiers')
@export var id: int
@export var subject_id: int
@export var created_at: int
@export var last_time_edited: int
@export var tags: Array

@export_category('Sensory Add-Ons')
@export var mediaset_id: int

@export_category('Data')
@export var question: PackedStringArray
@export var answer = [{"texts": [""]}]
@export var choices:= []
@export var columns: Array
@export var match_a: Dictionary
@export var match_b: Dictionary
@export var labels: Array
@export var variables:= []

@export var level: int = 1

@export_category('Question Types')
@export var is_open:= false
@export var is_choice:= false
@export var is_table:= false
@export var is_label:= false
@export var is_connect:= false

@export_category('Question Add-Ons')
@export var is_order: bool = false
@export var is_strict: bool = false
@export var is_gap: bool = false
@export var is_veracity: bool = false
@export var is_shuffle: bool = false

@export_category('Experience')
@export var parents: Array
@export var experience_level:= 1
@export var experience: float
@export var is_level_up_queued: bool
@export_group("Streaks")
@export var appearances: int
@export var hits: int
@export var misses: int
@export var hit_streak: int
@export var miss_streak: int
@export var last_time_leveled: float

@export_category("Quiz Answer")
@export var attempt := []
@export var attempt_index:= 0
@export var formulated_variables := []
@export var attempt_type: String
@export var is_rush:= false

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

func get_mediaset() -> Mediaset:
	return ResourceLoader.load("user://mediasets/" + str(mediaset_id).lpad(10, '0') + ".tres")

func get_or_create_mediaset() -> Mediaset:
	if has_media():
		return get_mediaset()
	else:
		var media = Mediaset.new()
		media.create()
		mediaset_id = media.id
		return media

func get_file_path() -> String:
	var subject_id_dir = str(subject_id).lpad(10, '0') + '/'
	var id_filename = str(id).lpad(10, '0') + '.tres'
	return "user://subjects/" + subject_id_dir + id_filename

func get_dictionary() -> Dictionary:
	var res: Dictionary
	var elements: PackedStringArray = [
	"question", "answer", "last_time_edited", "last_time_leveled",
	"subject_id", "created_at", "tags", "choices", "columns", "match_a",
	"match_b", "labels", "variables", "parents", "level", "experience_level",
	"is_level_up_queued", "appearances", "hits", "hit_streak", "misses",
	"miss_streak", "is_open", "is_choice", "is_table", "is_label", "is_connect",
	"is_order", "is_strict", "is_gap", "is_veracity", "is_shuffle"
	]
	for element in elements:
		res[element] = get(element)
	res["local_id"] = id
	return res

func absorb_dictionary(dict: Dictionary) -> void:
	id = dict["local_id"]
	question = JSON.parse_string(dict["question"])
	answer = JSON.parse_string(dict["answer"])
	last_time_edited = dict["last_time_edited"]
	last_time_leveled = dict["last_time_leveled"]
	subject_id = dict["subject_id"]
	created_at = dict["created_at"]
	tags = JSON.parse_string(dict["tags"])
	choices = JSON.parse_string(dict["choices"])
	columns = JSON.parse_string(dict["columns"])
	match_a = JSON.parse_string(dict["match_a"])
	match_b = JSON.parse_string(dict["match_b"])
	labels = JSON.parse_string(dict["labels"])
	# variables = JSON.parse_string(dict["variables"])
	parents = JSON.parse_string(dict["parents"])
	level = dict["level"]
	experience_level = dict["experience_level"]
	hits = dict["hits"]
	misses = dict["misses"]
	hit_streak = dict["hit_streak"]
	miss_streak = dict["miss_streak"]
	appearances = dict["appearances"]
	is_level_up_queued = dict["is_level_up_queued"]
	is_open = dict["is_open"]
	is_choice = dict["is_choice"]
	is_table = dict["is_table"]
	is_label = dict["is_label"]
	is_connect = dict["is_connect"]
	is_order = dict["is_order"]
	is_strict = dict["is_strict"]
	is_gap = dict["is_gap"]
	is_veracity = dict["is_veracity"]
	is_shuffle = dict["is_shuffle"]

func create() -> void:
	id = get_subject().next_question_id(true)
	save()

func erase(post:= true) -> void:
	DirAccess.remove_absolute(get_file_path())
	if post:
		Main.question_http.request("https://standardized-experience-cloud.adventureraldo.workers.dev/api/question/", ["Content-Type: application/json"], HTTPClient.METHOD_DELETE,
		JSON.stringify({"subject_id": subject_id, "local_id": id}))

func save(post:= true) -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
	if post:
		Main.question_http.request("https://standardized-experience-cloud.adventureraldo.workers.dev/api/question/", ["Content-type: application/json"], HTTPClient.METHOD_POST,
			JSON.stringify([get_dictionary()]))

func save_to_quiz(quiz_id: int, attempt_id:= id):
	appearances += 1
	attempt_index = attempt_id
	save(false)
	
	var quiz_id_dir = str(quiz_id).lpad(10, '0') + '/'
	var id_filename = str(DirAccess.get_files_at("user://quizzes/" + quiz_id_dir).size()).lpad(10, '0') + '.tres'
	ResourceSaver.save(self, "user://quizzes/" + quiz_id_dir + id_filename, ResourceSaver.FLAG_COMPRESS)

# ==============================================================================
# LEVELING
# ==============================================================================
func hit(is_in_journey:= false) -> void:
	hits += 1
	hit_streak += 1
	if ((!is_in_journey && hit_streak > 1) || is_in_journey || experience_level > 4 && miss_streak < 1) && !is_level_up_queued:
		var next_level = experience_level + 1
		hit_streak = 0
		experience_level = clampi(next_level, 1, 15)
		queue_level_up(next_level)
	miss_streak = 0
	save(false)
	var subj = get_subject()
	subj.experience += 1
	subj.save(false)

func miss(is_in_journey:= false) -> void:
	misses += 1
	miss_streak += 1
	hit_streak = 0
	if ((!is_in_journey && miss_streak > 1) || is_in_journey) && !is_level_up_queued && experience_level > 1:
		miss_streak = 0
		experience_level = clampi(experience_level - 1, 1, 15)
	save(false)
	var subj = get_subject()
	subj.experience -= 1
	subj.save(false)

func queue_level_up(to_level: int) -> void:
	is_level_up_queued = true
	var due_time:= 0.0
	match to_level:
		2: due_time = 15 * 60
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

func finish_level_up() -> void:
	var leveling_queues: Array[LevelingQueue] = Main.data.get_leveling_queues()
	leveling_queues = leveling_queues.filter(func (queue: LevelingQueue):
		return queue.question_id == id
	)
	for leveling_queue in leveling_queues:
		leveling_queue.process_leveling(9999999999.9)
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

func has_media() -> bool:
	return ![0, null].has(mediaset_id)
