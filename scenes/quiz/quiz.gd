extends Panel

var quiz: Quiz

@export var open_attempt: PackedScene
@export var battle_ost: AudioStream
@export var might_ost: AudioStream
@export var rush_ost: AudioStream
@export var ambush_opening_ost: AudioStream
@export var ambush_ending_ost: AudioStream
var might_mode:= false
var rush_mode:= false
var streak = 0

func _process(_delta: float) -> void:
	$TimeBar.set_time_string(str(int($Timer.time_left)) + "s")
	if $Timer.time_left <= 90 && !rush_mode && !$Timer.is_stopped():
		rush_mode = true
		rush()

func rush() -> void:
	if quiz.has_rush_questions():
		print("I do have rush questions.")
		$MightTransition.play("RESET")
		$BGM.stream = ambush_opening_ost
		$BGM.play()
		$Timer.paused = true
		$RushAnimation.play()
		await $RushAnimation.animation_finished
		$Blood.show()
		for node in get_tree().get_nodes_in_group("rush_questions"):
			await get_tree().create_timer(0.5).timeout
			node.show()
			node.grab_focus()
		if $BGM.playing:
			await $BGM.finished
		$RushAnimation.play_hide_dims()
		await $RushAnimation.animation_finished
		$Timer.paused = false
		$BGM.stream = ambush_ending_ost
	else:
		$BGM.stream = rush_ost
	$TimeBar.display()
	$RushLight/Anim.play("warn")
	$BGM.play()
	$MightTransition.play("RESET")
	$RushLoop.play("rush")
	
func _ready() -> void:
	quiz = Main.data.get_last_quiz()
	_on_rush_arrow_anim_animation_finished("")
	redo()

func add_questions() -> void:
	for question in quiz.get_questions():
		add_question(question)
		await get_tree().create_timer(0.1).timeout
		# new_question.grab_focus()

func add_question(question: Question) -> VBoxContainer:
	var new_attempt = open_attempt.instantiate()
	new_attempt.prepare(question)
	new_attempt.add_to_might.connect(might_increase)
	if question.is_rush:
		new_attempt.hide()
		new_attempt.add_to_group("rush_questions")
	$ScrollC/Elements/Attempts.add_child(new_attempt)
	return new_attempt
	
func might_increase(value: int) -> void:
	var new_value = clamp($MightTimer.time_left + value, 0.0, 30.1)
	$MightTimer.start(new_value)
	if !rush_mode && !might_mode && $MightTimer.time_left > 30.0:
		$MightTransition.play("might")
		might_mode = true
		

func redo() -> void:
	var timezone_offset = Main.data.get_timezone_offset_seconds()
	var start_time = Time.get_datetime_dict_from_unix_time(quiz.start_time + timezone_offset)
	var end_time = Time.get_datetime_dict_from_unix_time(quiz.end_time + timezone_offset)
	$ScrollC/Elements/Header/SubjectTitle.text = quiz.get_subject().title
	$ScrollC/Elements/Header/Year.text = str(end_time.year)
	var duration = "{s_hour}:{s_minute} — {e_hour}:{e_minute}".format({
		"s_hour": str(start_time.hour).lpad(2, "0"), "s_minute": str(start_time.minute).lpad(2, "0"),
		"e_hour": str(end_time.hour).lpad(2, "0"), "e_minute": str(end_time.minute).lpad(2, "0")
	})
	$ScrollC/Elements/Header/Date/Duration.text = duration
	for child in $ScrollC/Elements/Attempts.get_children():
		child.queue_free()
	add_questions()
	$BGM.stream = battle_ost
	$MightBGM.stream = might_ost
	var bgm_starting_point:= 0.0
	if streak > 1:
		bgm_starting_point += randf_range(0.1, 5.0)
	$BGM.play(bgm_starting_point)
	$MightBGM.play(bgm_starting_point)
	$Blood.hide()
	$TimeBar.reset()
	$Timer.start(quiz.end_time - quiz.start_time)
	# Might Start
	var questions = quiz.get_questions()
	if questions.size() > 0:
		if questions[0].hit_streak > 0:
			$MightTransition.play("might_start")
			might_mode = true
			$MightTimer.start(30.1)
	$RushAnimation.reset()

func make_new_quiz():
	var prev_subject_id = quiz.subject_id
	quiz = Quiz.new()
	quiz.subject_id = prev_subject_id
	quiz.id = Main.data.next_quiz_id()
	quiz.level = 2
	quiz.create()
	quiz.generate()
	randomize()
	var random_chance = [false, true, false]
	random_chance.shuffle()
	if random_chance[0]:
		quiz.generate_rush_questions()
	streak += 1

func _on_button_pressed() -> void:
	if quiz.has_rush_questions() && !rush_mode:
		$Timer.start(90.1)
		return
	might_mode = false
	rush_mode = false
	$RushLoop.stop()
	$Timer.stop()
	$TimeBar.stop()
	if !$Timer.is_stopped(): 
		return
	$MightTimer.stop()
	$MightTimer.wait_time = 0.01
	$MightTransition.play("RESET")
	var amount_of_questions = $ScrollC/Elements/Attempts.get_child_count()
	var grade = 0.0
	for child in $ScrollC/Elements/Attempts.get_children():
		var truth = child.solve()
		if truth: grade += 20.0 / amount_of_questions
	$Grade.text = str(grade).replace('.', ',').substr(0, 4)
	$BGM.stream = load("res://audio/tracks/score_{rank}.ogg".format({"rank": rank_grade(grade)}))
	$BGM.play()
	
	$RushLight/Anim.play("RESET")
	$BreakTimer.start(quiz.size() * 10.0)
	$EndBreak.show()

func rank_grade(grade: float) -> String:
	if grade >= 19.9:
		return 's'
	elif grade >= 14.5:
		return 'a'
	elif grade >= 12.0:
		return 'b'
	elif grade >= 9.5:
		return 'c'
	elif grade >= 8.0:
		return 'd'
	elif grade >= 5.0:
		return 'e'
	elif grade >= 0.1:
		return 'f'
	else:
		return 'g'

func _on_timer_timeout() -> void:
	_on_button_pressed()

func stop_break() -> void:
	$Grade.text = ""
	$EndBreak.hide()
	make_new_quiz()
	redo()

func _on_end_break_pressed() -> void:
	$BreakTimer.stop()
	$BreakTimer.timeout.emit()

func _on_might_timer_timeout() -> void:
	if might_mode && !rush_mode:
		$MightTransition.play("calm")
		might_mode = false
		$MightTimer.wait_time = 0.06


func _on_rush_loop_animation_finished(anim_name: StringName) -> void:
	$RushLoop.play(anim_name)


func _on_rush_arrow_anim_animation_finished(_anim_name: StringName) -> void:
	$RushArrowLoop/RushArrowAnim.play("loop")


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "warn":
		$RushLight/Anim.play("warn")
