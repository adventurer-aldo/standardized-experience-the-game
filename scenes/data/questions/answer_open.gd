extends VBoxContainer

signal alternatives_modified

@export var alternative_scene: PackedScene

func _on_add_pressed():
	var new_alternative = alternative_scene.instantiate()
	$Alternatives.add_child(new_alternative)
	alternatives_modified.connect(new_alternative.get_order)
	new_alternative.tree_exiting.connect(ab)
	emit_signal("alternatives_modified")

func ab():
	emit_signal("alternatives_modified")
