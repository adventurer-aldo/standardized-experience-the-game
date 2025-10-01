extends HBoxContainer

@export var alt_scene: PackedScene
@export var alt_is_on_left = false

func _ready() -> void:
	if alt_is_on_left:
		move_child($AddAlt, 0)

func _on_add_alt_pressed() -> void:
	$Column/Alts.add_child(alt_scene.instantiate())

func fetch() -> PackedStringArray:
	var arr = [$Column/TextMain.text]
	arr += $Column/Alts.get_children().map(func (alt): return alt.fetch())
	return PackedStringArray(arr)
