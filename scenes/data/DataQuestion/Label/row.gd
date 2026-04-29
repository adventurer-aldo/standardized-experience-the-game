extends HBoxContainer

signal delete_pressed(index)

@export var alt_scene: PackedScene

func _on_delete_pressed() -> void:
	delete_pressed.emit(get_index())
	queue_free()

func _on_add_alt_pressed() -> void:
	$Texts/Alts.add_child(alt_scene.instantiate())

func fetch() -> Array:
	var alts = $Texts/Alts.get_children().map(func (child): return child.fetch())
	return [$Texts/MainText.text] + alts

func replicate(array) -> void:
	$Texts/MainText.text = array[0]
