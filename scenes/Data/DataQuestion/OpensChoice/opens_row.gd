extends HBoxContainer

signal delete_pressed(index)

@export var alt_scene: PackedScene
@export var is_decoy:= false

func to_decoy() -> void:
		$Answer/Set/Text.placeholder_text = "A wrong answer to that question."

func _on_add_alt_pressed() -> void:
	$Answer/Alts.add_child(alt_scene.instantiate())

func _on_delete_answer_pressed() -> void:
	delete_pressed.emit(get_index())
	if get_parent().get_child_count() > 1:
		queue_free()
	elif get_parent().get_child_count() == 1:
		clean()

func should_delete_hide() -> void:
	if get_parent().get_child_count() > 1:
		$Answer/Set/DeleteAnswer.show()
	else:
		$Answer/Set/DeleteAnswer.hide()

func clean():
	$Answer/Set/Text.text = ""

func fetch() -> Array:
	var main = $Answer/Set/Text.text
	return [main] + $Answer/Alts.get_children().map(func (alt): return alt.fetch())

func show_order() -> void:
	$Answer/Set/Text/Order.show()
	$Answer/Set/Text/Order/Text.text = str(get_index() + 1)

func hide_order() -> void:
	$Answer/Set/Text/Order.hide()
