extends Control

func _ready():
	SFX.autoplay("standardized")
	$Buttons/BehindBegin/BeginButton.grab_focus()

func _on_download_button_pressed():
	SFX.autoplay("confirm")
	get_tree().change_scene_to_file("res://scenes/download.tscn")

func _on_begin_button_pressed():
	SFX.autoplay("confirm")
	$Buttons.hide()
	$Buttons2.show()
	$Buttons2/BehindData/DataButton.grab_focus()


func _on_back_button_pressed():
	SFX.autoplay("confirm")
	$Buttons.show()
	$Buttons2.hide()
	$Buttons/BehindBegin/BeginButton.grab_focus()

func _on_quiz_button_pressed():
	SFX.autoplay("confirm")
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")


func _on_data_button_pressed():
	SFX.autoplay("confirm")
	get_tree().change_scene_to_file("res://scenes/data/questions.tscn")

func _on_button_focus_entered():
	SFX.autoplay("move", false)
