extends HFlowContainer

@export var parent_packed_scene: PackedScene

func add_parent(id: int) -> void:
	if has_node(str(id)):
		get_node(str(id)).queue_free()
	else:
		var parent_scene = parent_packed_scene.instantiate()
		parent_scene.id = id
		add_child(parent_scene)
		parent_scene.name = str(id)

func fetch() -> Array:
	return get_children().map(func (parent): return parent.fetch())

func replicate(array: Array) -> void:
	get_children().map(func (parent): if !array.has(parent.fetch()): parent.queue_free())
	for parent_id in array:
		if !has_node(str(parent_id)):
			add_parent(parent_id)

func reset() -> void:
	get_children().map(func (child): child.queue_free())
