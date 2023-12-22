extends Control

func _ready():
	SFX.autoplay("standardized")

func _on_press_key_pressed():
	SFX.autoplay("confirm")
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")

func _on_begin_button_pressed():
	get_tree().change_scene_to_file("res://scenes/playground.tscn")
