extends Resource

@export var id: int
@export var question: PackedStringArray = [""]
@export var image: Image
@export var answers: Array
@export var choices: Array
@export var tags: PackedStringArray = []
@export var parents := []
@export_range(1, 4) var level := 0
@export var subject_id := 0
@export_group("Question Types")
@export var open: bool = false
@export var choice: bool = false
@export var veracity: bool = false
@export var fill: bool = false
@export var table: bool = false
@export var match: bool = false
@export_subgroup("Parameters")
@export var strict: bool = false
@export var order: bool = false
@export var enumerate: bool = false
@export_group("Statistics")
@export var appearances := 0
@export var hits := 0
@export var misses := 0
@export var hit_streak := 0
@export var miss_streak := 0
@export var spaced_level := 0
@export var next_checkup := 0

func get_types() -> PackedStringArray:
	var output = PackedStringArray()
	if open == true: output.push_back("open")
	if choice == true: output.push_back("choice")
	if veracity == true: output.push_back("veracity")
	if fill == true: output.push_back("fill")
	if table == true: output.push_back("table")
	if match == true: output.push_back("match")
	return output

func get_parameters() -> PackedStringArray:
	var output = PackedStringArray()
	if strict == true: output.push_back("strict")
	if choice == true: output.push_back("order")
	if veracity == true: output.push_back("enumerate")
	return output

func is_won():
	return hit_streak > 3

func is_lost():
	return miss_streak > 6

func progress_level():
	var marked_level = spaced_level
	if is_won():
		spaced_level += 1
	elif is_lost():
		spaced_level -= 1
	if !(marked_level == spaced_level):
		hit_streak = 0
		miss_streak = 0

func get_parents():
	var found_parents = []
	for parent in parents:
		found_parents.push_back(load("user://subjects/{subject}/{parent}.res".format({"subject": subject_id, "parent": parent})))
	return found_parents

func delete():
	DirAccess.remove_absolute("user://subjects/" + str(subject_id) + "/" + str(id) + ".res")

func save():
	ResourceSaver.save(self, "user://subjects/" + str(subject_id) + "/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)
