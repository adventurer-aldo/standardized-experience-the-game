extends ColorRect

var quiz = Main.data.get_last_quiz()

@export var open_attempt: PackedScene
@export var battle_ost: AudioStream
@export var might_ost: AudioStream

func _process(_delta: float) -> void:
	$TimeBar/TimeLabel.text = str(int($Timer.time_left)) + "s"
func _ready() -> void:
	redo()

func add_questions() -> void:
	for question in quiz.get_questions():
		var new_attempt = open_attempt.instantiate()
		new_attempt.prepare(question)
		new_attempt.add_to_rush.connect(rush_increase)
		$ScrollContainer/AttemptsContainer.add_child(new_attempt)

func rush_increase() -> void:
	$MightTimer.wait_time += 1.0
	if $MightTimer.wait_time >= 20.0 && $MightTimer.is_stopped():
		$MightTimer.wait_time = clamp($MightTimer.wait_time, 0.0, 20.0)
		$MightTransition.play("might")
		$MightTimer.start()

func redo() -> void:
	for child in $ScrollContainer/AttemptsContainer.get_children():
		child.queue_free()
	add_questions()
	$BGM.stream = battle_ost
	$MightBGM.stream = might_ost
	$BGM.play()
	$MightBGM.play()
	$Timer.start(120.0)

func hey():
	quiz.id = Main.data.next_quiz_id()
	# quiz.subject_id = 6
	quiz.create()
	quiz.generate()

func _on_button_pressed() -> void:
	$Timer.stop()
	if !$Timer.is_stopped(): return
	$MightTimer.stop()
	$MightTimer.wait_time = 0.01
	$MightTransition.play("RESET")
	var amount_of_questions = $ScrollContainer/AttemptsContainer.get_child_count()
	var grade = 0.0
	for child in $ScrollContainer/AttemptsContainer.get_children():
		var truth = child.solve()
		if truth: grade += 20.0 / amount_of_questions
	$Grade.text = str(grade).replace('.', ',')
	if grade >= 14.5: $BGM.stream = load("res://audio/tracks/score_great.ogg")
	elif grade >= 9.5: $BGM.stream = load("res://audio/tracks/score_good.ogg")
	else: $BGM.stream = load("res://audio/tracks/score_defeat.ogg")
	$BGM.play()
		
	$BreakTimer.start()
	$EndBreak.show()

func _on_timer_timeout() -> void:
	_on_button_pressed()

func stop_break() -> void:
	$Grade.text = ""
	hey()
	redo()

func _on_end_break_pressed() -> void:
	$BreakTimer.stop()
	$BreakTimer.timeout.emit()
	$EndBreak.hide()

func _on_might_timer_timeout() -> void:
	$MightTransition.play("calm")
