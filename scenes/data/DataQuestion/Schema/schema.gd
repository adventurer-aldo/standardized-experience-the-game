extends Control

@export var nodes: Array = []
@export var links: Array = []

const NODE_SIZE := Vector2(190, 104)
const HANDLE_SIZE := Vector2(24, 24)
const LONG_PRESS_MS := 280
const NEW_NODE_DISTANCE := 190.0

var toolbar: HBoxContainer
var scroll: ScrollContainer
var graph: Control
var links_layer: Control
var live_arrow: Line2D
var node_controls := {}
var dragging_node_id:= ""
var drag_offset:= Vector2.ZERO
var handle_origin_id:= ""
var handle_direction:= Vector2.ZERO
var handle_pressed_at:= 0
var handle_is_dragging:= false
var handle_end:= Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(0, 420)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build()
	_refresh()

func _process(_delta: float) -> void:
	if handle_origin_id != "" && !handle_is_dragging:
		if Time.get_ticks_msec() - handle_pressed_at >= LONG_PRESS_MS:
			handle_is_dragging = true
			_update_live_arrow()

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

func add_node(id: String, text: String, position:= Vector2.ZERO, mediaset_id:= 0) -> void:
	_sync_from_ui()
	if id.strip_edges() == "":
		id = _next_node_id()
	if position == Vector2.ZERO:
		position = _next_node_position()
	nodes.push_back({
		"id": id,
		"text": text,
		"texts": [text] if text.strip_edges() != "" else [id],
		"position": position,
		"mediaset_id": mediaset_id,
	})
	_refresh()

func add_link(from_id: String, to_id: String, label:= "", bidirectional:= false) -> void:
	_sync_from_ui()
	if from_id == "" || to_id == "" || from_id == to_id:
		return
	for link in links:
		if str(link.get("from", "")) == from_id && str(link.get("to", "")) == to_id:
			return
	links.push_back({
		"from": from_id,
		"to": to_id,
		"label": label,
		"bidirectional": bidirectional,
	})
	_redraw_links()

func _build() -> void:
	if has_node("Scroll"):
		return
	toolbar = HBoxContainer.new()
	toolbar.name = "Toolbar"
	toolbar.add_theme_constant_override("separation", 8)
	add_child(toolbar)

	var add_text = Button.new()
	add_text.text = "+ Text"
	add_text.pressed.connect(_on_add_text_pressed)
	toolbar.add_child(add_text)

	scroll = ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 42
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	add_child(scroll)

	graph = Control.new()
	graph.name = "Graph"
	graph.mouse_filter = Control.MOUSE_FILTER_PASS
	graph.custom_minimum_size = Vector2(3200, 2200)
	scroll.add_child(graph)

	links_layer = Control.new()
	links_layer.name = "Links"
	links_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	links_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	graph.add_child(links_layer)

	live_arrow = Line2D.new()
	live_arrow.width = 3
	live_arrow.default_color = Color(0.16, 0.46, 0.95)
	links_layer.add_child(live_arrow)

func _refresh() -> void:
	_ensure_nodes()
	for child in graph.get_children():
		if child != links_layer:
			child.queue_free()
	node_controls.clear()
	for node in nodes:
		_add_node_control(node)
	_redraw_links()

func _add_node_control(node: Dictionary) -> void:
	var node_id = str(node.get("id", ""))
	var box = Control.new()
	box.name = node_id
	box.custom_minimum_size = NODE_SIZE
	box.size = NODE_SIZE
	box.position = _node_position(node)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.gui_input.connect(_on_node_gui_input.bind(node_id, box))
	graph.add_child(box)
	node_controls[node_id] = box

	var background = Panel.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(background)

	var margin = MarginContainer.new()
	margin.name = "Margin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	box.add_child(margin)

	var layout = VBoxContainer.new()
	layout.name = "Content"
	layout.add_theme_constant_override("separation", 3)
	margin.add_child(layout)

	var text = LineEdit.new()
	text.name = "Text"
	text.text = str(node.get("text", node_id))
	text.placeholder_text = "Text"
	layout.add_child(text)

	var alternatives = VBoxContainer.new()
	alternatives.name = "Alternatives"
	layout.add_child(alternatives)
	var texts = Array(node.get("texts", [text.text]))
	for alt_index in range(1, texts.size()):
		var alt = LineEdit.new()
		alt.text = str(texts[alt_index])
		alt.placeholder_text = "Alternative"
		alternatives.add_child(alt)

	var add_alt = Button.new()
	add_alt.text = "+ Alternative"
	add_alt.pressed.connect(_on_add_alternative_pressed.bind(alternatives))
	layout.add_child(add_alt)

	_add_handle(box, node_id, Vector2(1, 0), Vector2(NODE_SIZE.x - HANDLE_SIZE.x, NODE_SIZE.y * 0.5 - HANDLE_SIZE.y * 0.5))
	_add_delete_button(box, node_id)

func _add_handle(box: Control, node_id: String, direction: Vector2, position: Vector2) -> void:
	var handle = Button.new()
	handle.text = "+"
	handle.focus_mode = Control.FOCUS_NONE
	handle.custom_minimum_size = HANDLE_SIZE
	handle.size = HANDLE_SIZE
	handle.position = position
	handle.mouse_filter = Control.MOUSE_FILTER_STOP
	handle.gui_input.connect(_on_handle_gui_input.bind(node_id, direction.normalized()))
	box.add_child(handle)

func _add_delete_button(box: Control, node_id: String) -> void:
	var delete = Button.new()
	delete.text = "-"
	delete.focus_mode = Control.FOCUS_NONE
	delete.custom_minimum_size = HANDLE_SIZE
	delete.size = HANDLE_SIZE
	delete.position = Vector2(NODE_SIZE.x - HANDLE_SIZE.x, 0)
	delete.pressed.connect(_delete_node.bind(node_id))
	box.add_child(delete)

func _on_add_text_pressed() -> void:
	add_node(_next_node_id(), "Text")

func _on_add_alternative_pressed(container: VBoxContainer) -> void:
	var alt = LineEdit.new()
	alt.placeholder_text = "Alternative"
	container.add_child(alt)
	alt.grab_focus()

func _on_node_gui_input(event: InputEvent, node_id: String, box: Control) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_node_id = node_id
			drag_offset = box.get_local_mouse_position()
		else:
			dragging_node_id = ""
	elif event is InputEventMouseMotion && dragging_node_id == node_id:
		var local_mouse = graph.get_local_mouse_position()
		box.position = local_mouse - drag_offset
		_set_node_position(node_id, box.position)
		_redraw_links()

func _on_handle_gui_input(event: InputEvent, node_id: String, direction: Vector2) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			handle_origin_id = node_id
			handle_direction = direction
			handle_pressed_at = Time.get_ticks_msec()
			handle_is_dragging = false
			handle_end = get_local_mouse_position()
		else:
			if handle_origin_id == "":
				return
			if handle_is_dragging:
				var target_id = _node_at_position(graph.get_local_mouse_position(), handle_origin_id)
				if target_id != "":
					add_link(handle_origin_id, target_id)
			else:
				_create_connected_node(handle_origin_id, handle_direction)
			handle_origin_id = ""
			handle_is_dragging = false
			if is_instance_valid(live_arrow):
				live_arrow.points = PackedVector2Array()
	elif event is InputEventMouseMotion && handle_origin_id == node_id:
		handle_end = graph.get_local_mouse_position()
		if Time.get_ticks_msec() - handle_pressed_at >= LONG_PRESS_MS:
			handle_is_dragging = true
		_update_live_arrow()

func _create_connected_node(from_id: String, direction: Vector2) -> void:
	var from_position = _node_position_by_id(from_id)
	var new_id = _next_node_id()
	var new_position = from_position + direction * NEW_NODE_DISTANCE
	new_position.x = max(0.0, new_position.x)
	new_position.y = max(0.0, new_position.y)
	add_node(new_id, "Text", new_position)
	add_link(from_id, new_id)

func _sync_from_ui() -> void:
	for node in nodes:
		var node_id = str(node.get("id", ""))
		var box = node_controls.get(node_id)
		if box == null:
			continue
		var text = box.get_node_or_null("Margin/Content/Text")
		if text == null:
			text = box.find_child("Text", true, false)
		var alternatives = box.get_node_or_null("Margin/Content/Alternatives")
		if alternatives == null:
			alternatives = box.find_child("Alternatives", true, false)
		var texts = []
		if text != null:
			node["text"] = text.text
			texts.push_back(text.text)
		if alternatives != null:
			for alt in alternatives.get_children():
				if alt is LineEdit && alt.text.strip_edges() != "":
					texts.push_back(alt.text)
		node["texts"] = texts
		node["position"] = box.position

func _ensure_nodes() -> void:
	for index in range(nodes.size()):
		if !(nodes[index] is Dictionary):
			nodes[index] = {"id": str(nodes[index]), "text": str(nodes[index])}
		if !nodes[index].has("id") || str(nodes[index]["id"]).strip_edges() == "":
			nodes[index]["id"] = _next_node_id()
		if !nodes[index].has("text"):
			nodes[index]["text"] = str(nodes[index]["id"])
		if !nodes[index].has("texts"):
			nodes[index]["texts"] = [str(nodes[index]["text"])]
		if !nodes[index].has("position") || nodes[index]["position"] == Vector2.ZERO:
			nodes[index]["position"] = _next_node_position(index)

func _next_node_id() -> String:
	var index = nodes.size() + 1
	while _has_node_id("node_" + str(index)):
		index += 1
	return "node_" + str(index)

func _has_node_id(node_id: String) -> bool:
	for node in nodes:
		if str(node.get("id", "")) == node_id:
			return true
	return false

func _next_node_position(index:= -1) -> Vector2:
	if index < 0:
		index = nodes.size()
	var columns = max(1, int(max(size.x, 640.0) / 230.0))
	return Vector2(24.0 + (index % columns) * 230.0, 58.0 + floori(index / columns) * 150.0)

func _node_center(node_id: String) -> Vector2:
	var box = node_controls.get(node_id)
	if box == null:
		return Vector2.INF
	return box.position + NODE_SIZE * 0.5

func _node_position(node: Dictionary) -> Vector2:
	return node.get("position", Vector2.ZERO)

func _node_position_by_id(node_id: String) -> Vector2:
	for node in nodes:
		if str(node.get("id", "")) == node_id:
			return _node_position(node)
	return Vector2.ZERO

func _set_node_position(node_id: String, position: Vector2) -> void:
	for node in nodes:
		if str(node.get("id", "")) == node_id:
			node["position"] = position
			return

func _node_at_position(position: Vector2, except_id:= "") -> String:
	for node_id in node_controls.keys():
		if node_id == except_id:
			continue
		var box = node_controls[node_id]
		if Rect2(box.position, NODE_SIZE).has_point(position):
			return node_id
	return ""

func _draw_arrow(from_position: Vector2, to_position: Vector2, color: Color, link_data = null) -> void:
	if from_position.distance_to(to_position) < 8.0:
		return
	var direction = (to_position - from_position).normalized()
	var start = from_position + direction * 70.0
	var end = to_position - direction * 70.0
	var line = Line2D.new()
	line.width = 3
	line.default_color = color
	line.points = PackedVector2Array([
		start,
		end,
		end - direction.rotated(0.55) * 13.0,
		end,
		end - direction.rotated(-0.55) * 13.0,
	])
	links_layer.add_child(line)
	if link_data != null:
		var jump = Button.new()
		jump.text = "x"
		jump.tooltip_text = "Delete connection"
		jump.focus_mode = Control.FOCUS_NONE
		jump.custom_minimum_size = Vector2(28, 24)
		jump.size = Vector2(28, 24)
		jump.position = ((start + end) * 0.5) - jump.size * 0.5
		jump.pressed.connect(_delete_link.bind(link_data))
		links_layer.add_child(jump)

func _redraw_links() -> void:
	if links_layer == null:
		return
	if !is_instance_valid(live_arrow):
		live_arrow = Line2D.new()
		live_arrow.width = 3
		live_arrow.default_color = Color(0.16, 0.46, 0.95)
		links_layer.add_child(live_arrow)
	for child in links_layer.get_children():
		if child != live_arrow:
			child.queue_free()
	for link in links:
		var from_position = _node_center(str(link.get("from", "")))
		var to_position = _node_center(str(link.get("to", "")))
		if from_position != Vector2.INF && to_position != Vector2.INF:
			_draw_arrow(from_position, to_position, Color(0.12, 0.22, 0.42), link)

func _update_live_arrow() -> void:
	if live_arrow == null || !is_instance_valid(live_arrow) || handle_origin_id == "":
		return
	var from_position = _node_center(handle_origin_id)
	var direction = (handle_end - from_position).normalized()
	live_arrow.points = PackedVector2Array([from_position + direction * 70.0, handle_end])

func _delete_link(link_data) -> void:
	for index in range(links.size()):
		if links[index] == link_data:
			links.remove_at(index)
			_redraw_links()
			return

func _delete_node(node_id: String) -> void:
	_sync_from_ui()
	for index in range(nodes.size()):
		if str(nodes[index].get("id", "")) == node_id:
			nodes.remove_at(index)
			break
	links = links.filter(func(link):
		return str(link.get("from", "")) != node_id && str(link.get("to", "")) != node_id
	)
	_refresh()
