extends Panel

@export var quiz_scene: PackedScene
@export var practice_subject: PackedScene
@export var data_subject_scene: PackedScene

func subject_pressed(id: int) -> void:
	var quiz = Quiz.new()
	quiz.id = Main.data.next_quiz_id()
	quiz.subject_id = id
	quiz.create()
	quiz.generate()
	get_tree().change_scene_to_packed(quiz_scene)

func _ready() -> void:
	$BGM.play()
	$Overlay/ScrollLoopAnim.play("scroll")
	$YellowLoop/ScrollAnim.play("move_out")
	for subject in Main.data.get_subjects():
		var new = practice_subject.instantiate()
		new.subject_id = subject.id
		new.set_title("Lv. " + str(subject.level) + ": " + subject.title)
		new.subject_pressed.connect(subject_pressed)
		$Practice/GridContainer.add_child(new)


func _on_subjects_pressed() -> void:
	add_child(data_subject_scene.instantiate())


func _on_exit_pressed() -> void:
	$Exit/ExitScroll.play("scroll")
	$ScreenDim.announce_text("You're about to leave, but we'll see you soon!")
	$Voice.random_play("exit")
	await $Voice.finished
	get_tree().quit()


func _on_scroll_loop_anim_animation_finished(_anim_name: StringName) -> void:
	$Overlay/ScrollLoopAnim.play("scroll")
