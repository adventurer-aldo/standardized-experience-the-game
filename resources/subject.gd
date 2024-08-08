@tool
class_name Subject
extends Resource

@export var id : int
@export var title := ""
@export var description := ""
@export var image: Image
@export var color: Color
@export var allow_duplicate_questions := true
@export var starred := false
@export var level := 1
@export var experience := 0.0
@export var last_time_edited = 0

func export() -> void:
	var text = ""
	for file in DirAccess.get_files_at("user://subjects/%s" % id):
		var question = load("user://subjects/%s/%s" % [id, file])
		text += " - " + Array(question.question).pick_random()
		text += "\n"
		var mapped_ans = question.answers.map(func i(answer): return Array(answer).pick_random())
		text += "\n".join(PackedStringArray(mapped_ans))
		text += "\n\n\n"
	FileAccess.open("res://export.txt", FileAccess.WRITE).store_string(text)

func create() -> void:
	save()

func save() -> void:
	if !DirAccess.dir_exists_absolute("user://subjects/%s" % id):
		DirAccess.make_dir_absolute("user://subjects/%s" % id)
	ResourceSaver.save(self, "user://subjects/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)

func get_question(question_id: int) -> Question:
	return ResourceLoader.load("user://subjects/" + str(id) + "/" + str(question_id) + ".res")

func get_questions() -> Array:
	var arr = []
	for file in DirAccess.get_files_at("user://subjects/" + str(id) + "/"):
		arr.push_back(ResourceLoader.load("user://subjects/" + str(id) + "/" + str(file)))
	return arr

func get_question_amount() -> int:
	return Array(DirAccess.get_files_at("user://subjects/" + str(id))).size()

# Gets the list of questions of a Subject sorted by ID and returns element positioned at requested index.
func get_question_by_order(index: int) -> Question:
	var array = DirAccess.get_files_at("user://subjects/" + str(id)) as PackedStringArray
	if array.size() > 0:
		return ResourceLoader.load( "user://subjects/" + str(id) + '/' + array[clamp(index, 0, array.size() - 1)])
	else:
		return null
