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

func save() -> void:
	ResourceSaver.save(self, "user://subjects/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)

func get_question(question_id: int) -> Question:
	return ResourceLoader.load("user://subjects/" + str(id) + "/" + str(question_id) + ".res")

# Gets the list of questions of a Subject sorted by ID and returns element positioned at requested index.
func get_question_by_order(index: int) -> Question:
	var array = DirAccess.get_files_at("user://subjects/" + str(id)) as PackedStringArray
	if array.size() > 0:
		return ResourceLoader.load( "user://subjects/" + str(id) + '/' + array[clamp(index, 0, array.size() - 1)])
	else:
		return null
