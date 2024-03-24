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
			return !get_question().answers.map(func i(answer):
				var att = attempt.map(func i(attemp): return attemp.to_lower())
				var ans = answer.map(func i(k): return k.to_lower())
				if intersects(att, ans):
					return true
				else:
					return false).has(false)
		"choice":
			return !attempt.map(func e(attempted_answer):
				return get_question().answers.map(
					func i(answer): 
						return answer.has(attempted_answer)
						).has(true)
				).has(false) && attempt.size() > 0

func get_quiz():
	return ResourceLoader.load("user://quizzes/" + str(quiz_id) + ".res")

func get_subject():
	return get_quiz().get_subject()

func get_question():
	return ResourceLoader.load("user://subjects/" + str(get_quiz().subject_id) + "/" + str(question_id) + ".res")

func save():
	ResourceSaver.save(self, "user://quizzes/" + str(quiz_id) + '/' + str(index) + ".res")

func intersects(arr1, arr2):
	var arr2_dict = {}
	for v in arr2:
		arr2_dict[v] = true

	for v in arr1:
		if arr2_dict.get(v, false):
			return true
	return false
