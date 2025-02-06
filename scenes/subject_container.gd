extends MarginContainer

@export var id: int
@export var title: String
@export var level: int
@export var xp: float

@export var questions_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubjectButton/IDBox/ID.text = str(id)
	$SubjectButton/Name.text = title
	$SubjectButton/Level.text = "Lv. " + str(level)
	$SubjectButton/Experience.value = xp
	var amount = get_amount()
	$SubjectButton/AmountPanel/Amount.text = str(amount)
	$SubjectButton/Experience.value = xp / (amount * 10) * 100

func get_amount():
	return Array(DirAccess.get_files_at("user://subjects/" + str(id))).size()

func _on_subject_button_pressed() -> void:
	var new_scene = questions_scene.instantiate()
	new_scene.subject_id = id
	add_child(new_scene)
