extends Resource

@export var index = 0
@export var attempt := []
@export var grade := 0.0
@export var variables:= []
@export var question_id: int
@export var question_sample: int
@export var choice_indexes := []
@export var type := "open"
@export var quiz_id: int

func respond(response):
	attempt = response
	# Checks for non-attempted answer
	if [] != (attempt.filter(func i(attempted_answer): return attempted_answer.strip_edges() != "")):
		if is_correct(): get_question().hit_up()
		else: get_question().miss_up()
	save()

func is_correct():
	match type:
		"open", "formula", "caption":
			return !attempt.map(func i(attempted_answer):
				return get_question().answers[attempt.find(attempted_answer)].has(attempted_answer)).has(false)
		"choice":
			pass

func get_quiz():
	return ResourceLoader.load("user://quizzes/" + str(quiz_id) + ".res")

func get_subject():
	return get_quiz().get_subject()

func get_question():
	return ResourceLoader.load("user://subjects/" + str(get_quiz().subject_id) + "/" + str(question_id) + ".res")

func save():
	ResourceSaver.save(self, "user://quizzes/" + str(quiz_id) + '/' + str(index) + ".res")
