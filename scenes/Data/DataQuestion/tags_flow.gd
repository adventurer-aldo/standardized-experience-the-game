extends HFlowContainer

@export var tag_packed_scene: PackedScene

func add_tag(text: String) -> void:
	if !get_children().map(func (tag): return tag.fetch().to_lower()).has(text.to_lower()):
		var tag_scene = tag_packed_scene.instantiate()
		tag_scene.set_text(text)
		add_child(tag_scene)

func fetch() -> Array:
	return get_children().map(func (tag): return tag.fetch())

func replicate(array: Array) -> void:
	get_children().map(func (tag): if !array.has(tag.fetch()): tag.queue_free())
	var fetched = fetch()
	for tag_text in array:
		if !fetched.has(str(tag_text)):
			add_tag(tag_text)

func reset() -> void:
	get_children().map(func (child): child.queue_free())
