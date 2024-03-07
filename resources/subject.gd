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

func save():
	ResourceSaver.save(self, "user://subjects/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)
