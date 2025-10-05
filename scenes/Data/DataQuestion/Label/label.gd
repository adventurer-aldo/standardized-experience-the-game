extends VBoxContainer

@export var open_row: PackedScene

var drawing_mode: bool = false
var is_drawing: bool = false
var start_pos: Vector2
var polygon_points: Array[Vector2] = []

var image: Image
var labels: Dictionary = {}  # {id: Area2D}
var current_label_id: int = -1
var next_label_id: int = 0

var live_line: Line2D = null
var live_poly: Polygon2D = null
var history: Array = []  # stack for undo
var used_colors = []

func _ready():
	# Live line
	live_line = Line2D.new()
	live_line.width = 2
	live_line.default_color = Color(0,1,0)
	add_child(live_line)

	# Live filled polygon
	live_poly = Polygon2D.new()
	live_poly.color = Color(0,1,0,0.3)
	add_child(live_poly)

	set_process_input(true)  # enable _input()


# GENERATE RANDOM COLOR
func generate_unique_color() -> Color:
	var opacity := 0.4
	var new_color : Color
	var max_attempts := 50
	var min_difference := 0.2  # similarity threshold (lower = stricter)
	
	for i in range(max_attempts):
		new_color = Color(randf(), randf(), randf(), opacity)
		var too_similar := false
		
		for c in used_colors:
			if abs(new_color.r - c.r) < min_difference \
			and abs(new_color.g - c.g) < min_difference \
			and abs(new_color.b - c.b) < min_difference:
				too_similar = true
				break
		
		if not too_similar:
			used_colors.append(new_color)
			return new_color
	
	# fallback if too many attempts fail
	used_colors.append(new_color)
	return new_color

func _on_add_label_pressed():
	current_label_id = next_label_id
	next_label_id += 1

	var area: Area2D = Area2D.new()
	$MainElements/Canvas.add_child(area)
	labels[current_label_id] = area

	var row = open_row.instantiate()
	row.delete_pressed.connect(_on_row_delete_pressed)
	$LabelRows.add_child(row)
	drawing_mode = true
	generate_unique_color()

func _on_row_delete_pressed(index):
	labels.erase(index)
	$MainElements/Canvas/Markers.get_child(index).queue_free()
	$MainElements/Canvas.get_child(index + 1).queue_free()

func _on_end_drawing_pressed():
	if is_drawing:
		var new_poly: PackedVector2Array
		if polygon_points.size() <= 1:
			new_poly = _circle_to_polygon(start_pos, 20.0, 24)
		else:
			new_poly = PackedVector2Array(polygon_points)

		var created_nodes = _add_or_merge_collision(new_poly)
		history.append(created_nodes)

		is_drawing = false
		live_line.points = []
		live_poly.polygon = PackedVector2Array()  # clear temporary polygon

func _on_undo_pressed():
	if history.is_empty():
		return
	var last_entry = history.pop_back()
	for node in last_entry:
		if node:
			node.queue_free()

func _input(event):
	if not drawing_mode or current_label_id == -1:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and $MainElements/Canvas.get_global_rect().has_point(event.global_position):
				start_pos = event.global_position - $MainElements/Canvas.global_position
				start_pos.x = clamp(start_pos.x, 0.0, $MainElements/Canvas.size.x)
				start_pos.y = clamp(start_pos.y, 0.0, $MainElements/Canvas.size.y)

				polygon_points.clear()
				polygon_points.append(start_pos)
				is_drawing = true

				live_line.points = [$MainElements/Canvas.global_position + start_pos]
				live_poly.polygon = PackedVector2Array([$MainElements/Canvas.global_position + start_pos])

			elif is_drawing or (event.pressed and not $MainElements/Canvas.get_global_rect().has_point(event.global_position)):
				_on_end_drawing_pressed()

	elif event is InputEventMouseMotion and is_drawing:
		var rect = $MainElements/Canvas.get_global_rect()
		var p = event.global_position - $MainElements/Canvas.global_position
		p.x = clamp(p.x, 0.0, rect.size.x)
		p.y = clamp(p.y, 0.0, rect.size.y)

		polygon_points.append(p)

		# Update live line
		live_line.points = []
		for pp in polygon_points:
			live_line.points.append($MainElements/Canvas.global_position + pp)

		# Update live polygon
		var poly_points: PackedVector2Array = PackedVector2Array()
		for pp in polygon_points:
			poly_points.append(pp + $MainElements/Canvas.global_position)
		live_poly.polygon = poly_points

# -----------------------
# ADD OR MERGE COLLISION
# -----------------------
func _add_or_merge_collision(new_points: PackedVector2Array) -> Array:
	var created_nodes: Array = []
	var area: Area2D = labels[current_label_id]
	var merged: PackedVector2Array = new_points
	var to_remove: Array[CollisionShape2D] = []

	for n in area.get_children():
		if not (n is CollisionShape2D):
			continue
		var col: CollisionShape2D = n
		var shp: ConvexPolygonShape2D = col.shape as ConvexPolygonShape2D
		if shp == null:
			continue
		var existing: PackedVector2Array = shp.points

		var inter: Array = Geometry2D.intersect_polygons(merged, existing)
		if inter.size() > 0:
			var uni: Array = Geometry2D.merge_polygons(merged, existing)
			if uni.size() > 0:
				merged = uni[0]
				to_remove.append(col)

	for col_rm in to_remove:
		if col_rm.has_meta("vis"):
			var vis_rm: Node = col_rm.get_meta("vis")
			if vis_rm:
				vis_rm.queue_free()
		col_rm.queue_free()

	var pieces: Array = Geometry2D.decompose_polygon_in_convex(merged)
	if pieces.size() == 0:
		pieces = [merged]

	for piece in pieces:
		var shape_new: ConvexPolygonShape2D = ConvexPolygonShape2D.new()
		shape_new.points = piece

		var col_new: CollisionShape2D = CollisionShape2D.new()
		col_new.shape = shape_new
		area.add_child(col_new)

		var vis: Polygon2D = Polygon2D.new()
		vis.polygon = piece
		vis.color = used_colors[current_label_id]
		area.add_child(vis)

		col_new.set_meta("vis", vis)

		created_nodes.append(col_new)
		created_nodes.append(vis)

	var b = area.get_children().filter(func (child): return child is Polygon2D)
	var c = []
	b.map(func (poly): 
		c.append_array(poly.polygon))
	c.sort_custom(func (first, second): return first.x > second.x)
	var min_x = (c[0].x + c[-1].x) / 2.0
	c.sort_custom(func (first, second): return first.y > second.y)
	var min_y = (c[0].y + c[-1].y) / 2.0
	var target_node
	if $MainElements/Canvas/Markers.get_child(current_label_id) == null:
		target_node = $Markers/Number.duplicate()
		target_node.text = str(current_label_id + 1)
		$MainElements/Canvas/Markers.add_child(target_node)
	else:
		target_node = $MainElements/Canvas/Markers.get_child(current_label_id)
	target_node.global_position.x = min_x
	target_node.global_position.y = min_y
	return created_nodes


# -----------------------
# CIRCLE TO POLYGON HELPER
# -----------------------
func _circle_to_polygon(center: Vector2, radius: float, sides: int) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in sides:
		var angle: float = TAU * i / sides
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return pts

func fetch() -> Array:
	return $LabelRows.get_children().map(func (row: Node): return {
		"text": row.fetch(), "area": labels[row.get_index()]
		})

func _on_end_pressed() -> void:
	drawing_mode = false


func _on_get_image_pressed() -> void:
	if DisplayServer.clipboard_has_image():
		image = DisplayServer.clipboard_get_image()
		$MainElements/Canvas.texture = ImageTexture.create_from_image(image)
