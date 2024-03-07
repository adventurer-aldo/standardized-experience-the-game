extends Node3D

func _ready():
	$AnimationPlayer.play("zooms")
	BGM.autoplay("title")


func _on_subjects_pressed():
	add_child(load("res://scenes/data/subjects.tscn").instantiate())

func _on_quiz_pressed():
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")

func _on_download_pressed():
	get_tree().change_scene_to_file("res://scenes/download.tscn")
