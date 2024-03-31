@tool
class_name Question
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
@export var is_level_up_queued := false
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

func is_won() -> bool:
	return hit_streak >= 3

func is_lost() -> bool:
	return miss_streak >= 6

func progress_level() -> void:
	if is_level_up_queued: return
	var marked_level = spaced_level
	if is_won():
		marked_level += 1
		is_level_up_queued = true
		queue_spaced_level_up(marked_level, level_up_time(marked_level))
	elif is_lost():
		spaced_level = clamp(spaced_level - 1, 1, 99)
	if !(marked_level == spaced_level):
		hit_streak = 0
		miss_streak = 3
	save()

func level_up_time(to_level: int) -> int:
	match to_level:
		2: return 20*60
		3: return 1*60*60
		4: return 2*60*60
		5: return 8*60*60
		6: return 24*60*60
		7: return 3*24*60*60
		8: return 7*24*60*60
		9: return 15*24*60*60
		10: return 30*24*60*60
		11: return 45*24*60*60
	return 0

func queue_spaced_level_up(to_level: int, time: int = 1200) -> void: # Time is in seconds
	var queue = load("res://resources/queue.tres")
	queue.id = Global.stats.last_queue_id + 1
	queue.subject_id = subject_id
	queue.question_id = id
	queue.scheduled_time = Time.get_unix_time_from_system() + time
	queue.to_spaced_level = to_level
	Global.stats.last_queue_id = queue.id
	Global.stats.save()
	queue.save()

func hit_up() -> void:
	hits += 1
	hit_streak += 1
	miss_streak = 0
	progress_level()

func miss_up() -> void:
	misses += 1
	miss_streak += 1
	hit_streak = 0
	progress_level()

func get_parents() -> Array:
	var found_parents = []
	for parent in parents:
		found_parents.push_back(load("user://subjects/{subject}/{parent}.res".format({"subject": subject_id, "parent": parent})))
	return found_parents

func are_parents_won() -> bool:
	return !get_parents().map(func i(parent): return parent.spaced_level > 2).has(false)

func delete() -> void:
	DirAccess.remove_absolute("user://subjects/" + str(subject_id) + "/" + str(id) + ".res")

func save() -> void:
	ResourceSaver.save(self, "user://subjects/" + str(subject_id) + "/" + str(id) + ".res", ResourceSaver.FLAG_COMPRESS)
