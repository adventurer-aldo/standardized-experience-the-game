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

func save():
	ResourceSaver.save(self, "user://subjects/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)

func get_question(question_id: int):
	ResourceLoader.load("user://subjects/" + str(id) + "/" + str(question_id) + ".res")
