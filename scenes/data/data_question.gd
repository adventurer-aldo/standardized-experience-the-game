extends Control

signal question_alt_changed

signal might_started
signal might_ended

@export var question_packed_scene: PackedScene
@export var saved_question_packed_scene: PackedScene
var subject_id: int
var title = "Default Subject"
var question = Question.new()
var subject: Subject
@export var silence = false
var search_thread = Thread.new()

var might_mode:= false

func _ready() -> void:
	question.subject_id = subject_id
	subject = Main.data.get_subject(subject_id)
	$SubjectBar/Title.text = title
	_on_add_question_alt_pressed()
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = true
	_on_open_pressed()
	set_container()
	
	if silence:
		$BGM.stop()
		$MightBGM.stop()

func might_boost(value: float) -> void:
	var new_value = clamp($MightTimer.time_left + value, 0.0, 30.1)
	$MightTimer.start(new_value)
	if !might_mode:
		$MightTransitions.play("might")
		might_mode = true
		might_started.emit()

func _on_might_timer_timeout() -> void:
	if might_mode && $MightTimer.time_left > 120.0:
		$MightTransitions.play("calm")
		might_mode = false
		$MightTimer.wait_time = 0.06
		might_ended.emit()

func _on_reset_pressed() -> void:
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Question/Texts.get_child(0).get_focus()
	$Items/ScrollData/Data/Opens.reset(true)
	
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.reset()
	$Items/ScrollData/Data/TagsContainer/TagsFlow.reset()
	question.id = 0

func set_container() -> void:
	question.get_subject().get_questions().map(func (saved_question):
		# var a = Thread.new()
		# a.start(add_question_to_container.bind(saved_question))
		add_question_to_container(saved_question)
	)

func add_question_to_container(saved_question: Question) -> void:
	var question_to_add
	var container_node = $QuestionsScroll/QuestionsContainer
	if container_node.has_node(str(saved_question.id)):
		question_to_add = container_node.get_node(str(saved_question.id))
	else:
		question_to_add = saved_question_packed_scene.instantiate()
		question_to_add.parent_pressed.connect(on_parent_pressed)
		question_to_add.edit_pressed.connect(on_edit_pressed)
		question_to_add.delete_pressed.connect(on_grid_delete_pressed)
		question_to_add.name = str(saved_question.id)
		question_to_add.id = saved_question.id
	question_to_add.set_text(saved_question.question[0])
	question_to_add.set_level(saved_question.experience_level)
	container_node.add_child(question_to_add)
	container_node.move_child(question_to_add, 0)
	$SubjectBar/AmountBar/Amount.text = str(container_node.get_child_count()).lpad(2, '0')

func _on_add_question_alt_pressed() -> void:
	var q_scene = question_packed_scene.instantiate()
	$Items/ScrollData/Data/Question/Texts.add_child(q_scene)
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() + 1)
	question_alt_changed.connect(q_scene.refresh)
	q_scene.delete_pressed.connect(_on_question_delete_pressed)
	
func _on_question_delete_pressed() -> void:
	print("Alt changed")
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() - 1)

func _on_open_pressed() -> void:
	if question.get_types().size() == 1 && question.is_open: return
	question.is_open = !question.is_open
	$Items/ScrollData/Data/Opens.visible = question.is_open

func _on_choice_pressed() -> void:
	if question.get_types().size() == 1 && question.is_choice: return
	question.is_choice = !question.is_choice
	$Items/ScrollData/Data/Opens.visible = (question.is_open || question.is_choice)
	$Items/ScrollData/Data/Choices.visible = question.is_choice

func _on_match_pressed() -> void:
	if question.get_types().size() == 1 && question.is_connect: return
	question.is_connect = !question.is_connect
	$Items/ScrollData/Data/Match.visible = question.is_connect

func _on_table_pressed() -> void:
	if question.get_types().size() == 1 && question.is_table: return
	question.is_table = !question.is_table
	$Items/ScrollData/Data/Table.visible = question.is_table

func _on_label_pressed() -> void:
	if question.get_types().size() == 1 && question.is_label: return
	question.is_label = !question.is_label
	$Items/ScrollData/Data/Label.visible = question.is_label

func _on_ordered_pressed() -> void:
	question.is_order = !question.is_order

func _on_strict_pressed() -> void:
	question.is_strict = !question.is_strict

func _on_gap_pressed() -> void:
	question.is_gap = !question.is_gap

func _on_veracity_pressed() -> void:
	question.is_veracity = !question.is_veracity

func _on_shuffle_pressed() -> void:
	question.is_shuffle = !question.is_shuffle

func fetch_question_texts() -> PackedStringArray:
	var strings = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row):
		return question_row.fetch()
	)
	return PackedStringArray(strings)

func _on_increase_level_pressed() -> void:
	change_level([1, 2, 3, 4, 1][question.level])

func change_level(to: int) -> void:
	question.level = to
	var tar = $Items/ScrollData/Data/Question/GloballyRelevant/IncreaseLevel/Elements/Text
	var texts = ['Beginner Level', 'Advanced Level', 'Dissertation', 'Master Level']
	tar.text = texts[to - 1]

func _on_add_tag_button_pressed() -> void:
	var text: String = $Items/ScrollData/Data/Tag/Text.text.strip_edges()
	$Items/ScrollData/Data/TagsContainer/TagsFlow.add_tag(text)
	$Items/ScrollData/Data/Tag/Text.text = ""

func on_parent_pressed(id: int) -> void:
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.add_parent(id)

func on_grid_delete_pressed(id: int) -> void:
	question.get_subject().erase_question(id)

func on_edit_pressed(id: int) -> void:
	var to_edit = question.get_subject().get_question(id)
	var questions_difference = to_edit.question.size() - $Items/ScrollData/Data/Question/Texts.get_child_count()
	if questions_difference > 0:
		for i in range(questions_difference):
			_on_add_question_alt_pressed()
	elif questions_difference < 0:
		for i in range(questions_difference * -1):
			$Items/ScrollData/Data/Question/Texts.get_child((i * -1) -1).queue_free()
	for i in range(to_edit.question.size()):
		$Items/ScrollData/Data/Question/Texts.get_child(i - 1).set_text(to_edit.question[i - 1])
	
	if to_edit.has_media():
		$Items/ScrollData/Data/Question/Image.texture = to_edit.get_mediaset().images[0]
	$Items/ScrollData/Data/Opens.replicate(to_edit.answer)
	
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.replicate(to_edit.parents)
	$Items/ScrollData/Data/TagsContainer/TagsFlow.replicate(to_edit.tags)
	question.id = id
	question.experience_level = to_edit.experience_level
	question.hits = to_edit.hits
	question.misses = to_edit.misses
	question.hit_streak = to_edit.hit_streak
	question.miss_streak	 = to_edit.miss_streak	
	change_level(to_edit.level)

func fetch_data() -> void:
	question.question = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row): return question_row.fetch())
	question.created_at = Time.get_unix_time_from_system()
	question.last_time_edited = question.created_at
	question.answer = $Items/ScrollData/Data/Opens.fetch()
	question.choices = $Items/ScrollData/Data/Choices.fetch()
	question.columns = $Items/ScrollData/Data/Table.fetch()
	var matches = $Items/ScrollData/Data/Match.fetch()
	question.match_a = matches["a"]
	question.match_b = matches["b"]
	question.labels = $Items/ScrollData/Data/Label.fetch()
	
	question.tags = $Items/ScrollData/Data/TagsContainer/TagsFlow.fetch()
	question.parents = $Items/ScrollData/Data/ParentsContainer/ParentsFlow.fetch()
	var images = [$Items/ScrollData/Data/Question/Image.texture]
	for image in images.filter(func (img): return img != null):
		question.get_or_create_mediaset().add_image(image)

func play_submit_edit_voice() -> void:
	if question.get_subject().has_question(question.id):
		$Voice.random_play("questions_edit", 1.0)
	else:
		if DirAccess.dir_exists_absolute("res://audio/voice/questions_" + str(question.get_subject().size())):
			$Voice.random_play("questions_" + str(question.get_subject().size()), 1.0)
		else:
			$Voice.random_play("questions_new", 1.0)

func _on_submit_pressed() -> void:
	might_boost(45.0)
	play_submit_edit_voice()
	fetch_data()
	# Save or Edit Question. Also edit the Subject's last time saved variable.
	if subject.has_question(question.id):
		question.save()
	else:
		question.create()
		subject.maximum_experience += 1

	subject.last_time_saved = Time.get_unix_time_from_system()
	subject.save()
	add_question_to_container(question)
	$SFX.play_file("submit")
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Question/Texts.get_child(0).get_focus()
	$Items/ScrollData/Data/Question/Image.texture = null
	$Items/ScrollData/Data/Opens.reset()
	question.id = 0

func _on_close_pressed() -> void:
	queue_free()

func _on_images_pressed() -> void:
	var img = DisplayServer.clipboard_get_image()
	$Items/ScrollData/Data/Question/Image.texture = ImageTexture.create_from_image(img)


func _on_search_bar_text_changed(new_text: String) -> void:
	for question_query in $QuestionsScroll/QuestionsContainer.get_children():
		if new_text.strip_edges() == '':
			question_query.show()
		else:
			var target_title: String = question_query.get_text()
			if !target_title.containsn(new_text):
				question_query.hide()
			else:
				question_query.show()
