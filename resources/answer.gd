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
	if [].size() != (attempt.filter(func i(attempted_answer): 
		return attempted_answer.strip_edges() != "")
		).size():
		if is_correct(): 
			get_question().hit_up()
		else: 
			get_question().miss_up()
	save()

func is_correct():
	match type:
		"open", "formula", "caption":
			var answers = get_question().answers.duplicate()
			for answer in answers:
				var found_match = false
				for att in attempt:
					if answer.map(func i(ans): return ans.to_lower()).has(att.to_lower()): 
						answers.erase(answer)
						found_match = true
						break
				if found_match == true: break
			return answers.size() == 0
			#return !attempt.map(func i(attempted_answer):
			#	return get_question().answers[attempt.find(attempted_answer)].has(attempted_answer)).has(false)
		"choice":
			return !attempt.map(func e(attempted_answer):
				print(get_question().answers)
				return get_question().answers.map(
					func i(answer): 
						return answer.has(attempted_answer)
						).has(true)
				).has(false)

func get_quiz():
	return ResourceLoader.load("user://quizzes/" + str(quiz_id) + ".res")

func get_subject():
	return get_quiz().get_subject()

func get_question():
	return ResourceLoader.load("user://subjects/" + str(get_quiz().subject_id) + "/" + str(question_id) + ".res")

func save():
	ResourceSaver.save(self, "user://quizzes/" + str(quiz_id) + '/' + str(index) + ".res")
