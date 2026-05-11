extends "res://scenes/quiz/attempt_base.gd"

const SCHEMA_SCENE := preload("res://scenes/data/DataQuestion/Schema/schema.tscn")

var scheme_editor: Control

func _build_attempt_controls() -> void:
	var nodes = question.scheme_nodes
	if question.formulated_variables.size() >= 1:
		nodes = question.formulated_variables[0]
	scheme_editor = SCHEMA_SCENE.instantiate()
	scheme_editor.name = "SchemeAttempt"
	scheme_editor.custom_minimum_size = Vector2(0, 360)
	scheme_editor.allow_alternatives = false
	body.add_child(scheme_editor)
	scheme_editor.replicate({"nodes": nodes, "links": []})

func fetch() -> Array:
	if scheme_editor != null && scheme_editor.has_method("fetch"):
		return scheme_editor.fetch().get("links", [])
	return []

func _show_checked_result(result: Dictionary) -> void:
	super._show_checked_result(result)
	if result.get("missing_answers", []).is_empty():
		return
	var missing = Label.new()
	missing.text = "Some required links are missing."
	missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	missing.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07))
	body.add_child(missing)
