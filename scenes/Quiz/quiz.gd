extends ColorRect

var quiz = Main.data.get_last_quiz()

@export var open_attempt: PackedScene
@export var battle_ost: AudioStream
@export var might_ost: AudioStream
var might_mode:= false

func _process(_delta: float) -> void:
	$TimeBar/TimeLabel.text = str(int($Timer.time_left)) + "s"
	$DebugLabel.text = str($MightTimer.time_left)
	$DebugLabel2.text = str($MightTimer.wait_time)

func _ready() -> void:
	redo()

func add_questions() -> void:
	for question in quiz.get_questions():
		var new_attempt = open_attempt.instantiate()
		new_attempt.prepare(question)
		new_attempt.add_to_rush.connect(rush_increase)
		$ScrollContainer/AttemptsContainer.add_child(new_attempt)

func rush_increase(value: int) -> void:
	var new_value = clamp($MightTimer.time_left + value, 0.0, 20.1)
	$MightTimer.start(new_value)
	if !might_mode && $MightTimer.time_left > 20.0:
		$MightTransition.play("might")
		might_mode = true
		

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
	might_mode = false
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
	if grade >= 20.0: $BGM.stream = load("res://audio/tracks/score_greatest.ogg")
	elif grade >= 14.5: $BGM.stream = load("res://audio/tracks/score_great.ogg")
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
	if might_mode:
		$MightTransition.play("calm")
		might_mode = false
		$MightTimer.wait_time = 0.06
