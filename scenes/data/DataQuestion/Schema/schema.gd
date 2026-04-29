extends Control

@export var nodes: Array = []
@export var links: Array = []

var nodes_list: VBoxContainer
var links_list: VBoxContainer
var node_id: LineEdit
var node_text: LineEdit
var link_from: LineEdit
var link_to: LineEdit
var link_label: LineEdit
var dragging_node_index:= -1
const GRAPH_TOP:= 128.0
const NODE_RADIUS:= 24.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build()
	_refresh()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_node_index = _find_node_at(event.position)
		else:
			dragging_node_index = -1
	elif event is InputEventMouseMotion && dragging_node_index >= 0:
		nodes[dragging_node_index]["position"] = event.position
		queue_redraw()

func _draw() -> void:
	_ensure_node_positions()
	for link in links:
		var from_position = _get_node_position(str(link.get("from", "")))
		var to_position = _get_node_position(str(link.get("to", "")))
		if from_position != Vector2.INF && to_position != Vector2.INF:
			draw_line(from_position, to_position, Color(0.15, 0.25, 0.45), 3.0)
			var direction = (to_position - from_position).normalized()
			var arrow_center = to_position - direction * NODE_RADIUS
			draw_line(arrow_center, arrow_center - direction.rotated(0.55) * 12.0, Color(0.15, 0.25, 0.45), 3.0)
			draw_line(arrow_center, arrow_center - direction.rotated(-0.55) * 12.0, Color(0.15, 0.25, 0.45), 3.0)
	for node in nodes:
		var position = _get_position_from_node(node)
		draw_circle(position, NODE_RADIUS, Color(0.93, 0.96, 1.0))
		draw_arc(position, NODE_RADIUS, 0.0, TAU, 32, Color(0.12, 0.22, 0.42), 3.0)
		var label = _scheme_node_id(node)
		draw_string(get_theme_default_font(), position + Vector2(-NODE_RADIUS + 4.0, 5.0), label, HORIZONTAL_ALIGNMENT_LEFT, NODE_RADIUS * 2.0, 14, Color(0.04, 0.08, 0.16))

func fetch() -> Dictionary:
	_sync_from_ui()
	return {
		"nodes": nodes.duplicate(true),
		"links": links.duplicate(true),
	}

func replicate(data: Dictionary) -> void:
	nodes = data.get("nodes", []).duplicate(true)
	links = data.get("links", []).duplicate(true)
	_refresh()
	queue_redraw()

func add_node(id: String, text: String, position:= Vector2.ZERO, mediaset_id:= 0) -> void:
	if position == Vector2.ZERO:
		position = _next_node_position()
	nodes.push_back({
		"id": id,
		"text": text,
		"position": position,
		"mediaset_id": mediaset_id,
	})
	_refresh()
	queue_redraw()

func add_link(from_id: String, to_id: String, label:= "", bidirectional:= false) -> void:
	links.push_back({
		"from": from_id,
		"to": to_id,
		"label": label,
		"bidirectional": bidirectional,
	})
	_refresh()
	queue_redraw()

func _build() -> void:
	if has_node("Editor"):
		return
	var editor = VBoxContainer.new()
	editor.name = "Editor"
	editor.add_theme_constant_override("separation", 8)
	add_child(editor)

	var title = Label.new()
	title.text = "Scheme"
	editor.add_child(title)

	var node_row = HBoxContainer.new()
	node_row.add_theme_constant_override("separation", 6)
	editor.add_child(node_row)
	node_id = LineEdit.new()
	node_id.placeholder_text = "Node ID"
	node_row.add_child(node_id)
	node_text = LineEdit.new()
	node_text.placeholder_text = "Node Text"
	node_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node_row.add_child(node_text)
	var add_node_button = Button.new()
	add_node_button.text = "+ Node"
	add_node_button.pressed.connect(_on_add_node_pressed)
	node_row.add_child(add_node_button)

	nodes_list = VBoxContainer.new()
	nodes_list.name = "Nodes"
	editor.add_child(nodes_list)

	var link_row = HBoxContainer.new()
	link_row.add_theme_constant_override("separation", 6)
	editor.add_child(link_row)
	link_from = LineEdit.new()
	link_from.placeholder_text = "From"
	link_row.add_child(link_from)
	link_to = LineEdit.new()
	link_to.placeholder_text = "To"
	link_row.add_child(link_to)
	link_label = LineEdit.new()
	link_label.placeholder_text = "Label"
	link_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link_row.add_child(link_label)
	var add_link_button = Button.new()
	add_link_button.text = "+ Link"
	add_link_button.pressed.connect(_on_add_link_pressed)
	link_row.add_child(add_link_button)

	links_list = VBoxContainer.new()
	links_list.name = "Links"
	editor.add_child(links_list)

func _refresh() -> void:
	if nodes_list == null:
		return
	_ensure_node_positions()
	for child in nodes_list.get_children():
		child.queue_free()
	for node in nodes:
		nodes_list.add_child(_make_item_row(_scheme_node_text(node), _remove_node.bind(node)))
	for child in links_list.get_children():
		child.queue_free()
	for link in links:
		links_list.add_child(_make_item_row(_scheme_link_text(link), _remove_link.bind(link)))

func _make_item_row(text: String, delete_callable: Callable) -> HBoxContainer:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var delete = Button.new()
	delete.text = "-"
	delete.pressed.connect(delete_callable)
	row.add_child(delete)
	return row

func _on_add_node_pressed() -> void:
	var id = node_id.text.strip_edges()
	if id == "":
		id = node_text.text.strip_edges()
	if id == "":
		return
	add_node(id, node_text.text.strip_edges())
	node_id.text = ""
	node_text.text = ""

func _on_add_link_pressed() -> void:
	if link_from.text.strip_edges() == "" || link_to.text.strip_edges() == "":
		return
	add_link(link_from.text.strip_edges(), link_to.text.strip_edges(), link_label.text.strip_edges())
	link_from.text = ""
	link_to.text = ""
	link_label.text = ""

func _remove_node(node) -> void:
	nodes.erase(node)
	var node_id_to_remove = _scheme_node_id(node)
	links = links.filter(func(link): return str(link.get("from", "")) != node_id_to_remove && str(link.get("to", "")) != node_id_to_remove)
	_refresh()
	queue_redraw()

func _remove_link(link) -> void:
	links.erase(link)
	_refresh()
	queue_redraw()

func _sync_from_ui() -> void:
	pass

func _scheme_node_id(node) -> String:
	if node is Dictionary:
		return str(node.get("id", node.get("text", "")))
	return str(node)

func _scheme_node_text(node) -> String:
	if node is Dictionary:
		return str(node.get("id", "")) + " - " + str(node.get("text", ""))
	return str(node)

func _scheme_link_text(link) -> String:
	if link is Dictionary:
		var label = str(link.get("label", ""))
		return str(link.get("from", "")) + " -> " + str(link.get("to", "")) + ((" : " + label) if label != "" else "")
	return str(link)

func _ensure_node_positions() -> void:
	for index in range(nodes.size()):
		if !(nodes[index] is Dictionary):
			nodes[index] = {"id": str(nodes[index]), "text": str(nodes[index]), "position": _next_node_position(index)}
		if !nodes[index].has("position") || nodes[index]["position"] == Vector2.ZERO:
			nodes[index]["position"] = _next_node_position(index)

func _next_node_position(index:= -1) -> Vector2:
	if index < 0:
		index = nodes.size()
	var width = max(size.x, 420.0)
	var columns = max(1, int(width / 140.0))
	return Vector2(70.0 + (index % columns) * 130.0, GRAPH_TOP + 70.0 + floori(index / columns) * 86.0)

func _get_node_position(node_id: String) -> Vector2:
	for node in nodes:
		if _scheme_node_id(node) == node_id:
			return _get_position_from_node(node)
	return Vector2.INF

func _get_position_from_node(node) -> Vector2:
	if node is Dictionary:
		return node.get("position", Vector2.ZERO)
	return Vector2.ZERO

func _find_node_at(position: Vector2) -> int:
	for index in range(nodes.size() - 1, -1, -1):
		if _get_position_from_node(nodes[index]).distance_to(position) <= NODE_RADIUS:
			return index
	return -1
