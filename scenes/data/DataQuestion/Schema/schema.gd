extends Control

@export var nodes: Array = []
@export var links: Array = []

func fetch() -> Dictionary:
	return {
		"nodes": nodes.duplicate(true),
		"links": links.duplicate(true),
	}

func replicate(data: Dictionary) -> void:
	nodes = data.get("nodes", []).duplicate(true)
	links = data.get("links", []).duplicate(true)

func add_node(id: String, text: String, position:= Vector2.ZERO, mediaset_id:= 0) -> void:
	nodes.push_back({
		"id": id,
		"text": text,
		"position": position,
		"mediaset_id": mediaset_id,
	})

func add_link(from_id: String, to_id: String, label:= "", bidirectional:= false) -> void:
	links.push_back({
		"from": from_id,
		"to": to_id,
		"label": label,
		"bidirectional": bidirectional,
	})

func _on_area_2d_mouse_entered() -> void:
	print("Mouse entered")


func _on_area_2d_mouse_exited() -> void:
	print("Mouse exited")


func _on_button_text_changed() -> void:
	$Button/Area2D/CollisionShape2D.shape.size = $Button.size
	$Button/Area2D.position = Vector2($Button.position.x / 2.0, $Button.position.y / 2.0)
