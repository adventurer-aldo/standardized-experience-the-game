extends Control

signal question_alt_changed

@export var question_packed_scene: PackedScene

func _ready() -> void:
	_on_add_question_alt_pressed()

func _on_add_question_alt_pressed() -> void:
	var q_scene = question_packed_scene.instantiate()
	$Items/Data/Question/Texts.add_child(q_scene)
	question_alt_changed.emit($Items/Data/Question/Texts.get_child_count() + 1)
	question_alt_changed.connect(q_scene.refresh)
	q_scene.delete_pressed.connect(_on_question_delete_pressed)
	# q_scene.tree_exited.connect(_on_question_delete_pressed)
	
func _on_question_delete_pressed() -> void:
	print("Alt changed")
	# await get_tree().create_timer(1).timeout
	question_alt_changed.emit($Items/Data/Question/Texts.get_child_count() - 1)
