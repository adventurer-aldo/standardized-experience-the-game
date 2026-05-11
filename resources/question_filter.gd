class_name QuestionFilter
extends RefCounted

const ANY_LEVEL := 0

static func apply(questions: Array, subject: Subject, options:= {}) -> Array:
	var filtered := questions.duplicate()
	filtered = filter_by_quiz_level(filtered, int(options.get("quiz_level", ANY_LEVEL)))
	filtered = filter_by_question_types(filtered, Array(options.get("types", [])))
	filtered = filter_by_tags(filtered, Array(options.get("tags", [])))
	filtered = filter_by_parent_ids(
		filtered,
		subject,
		Array(options.get("parent_ids", [])),
		bool(options.get("include_parent_ancestors", true))
	)
	if bool(options.get("block_unsolved_parents", false)):
		filtered = filtered.filter(func(question: Question): return question.are_parents_decent())
	if bool(options.get("exclude_level_up_queued", true)):
		filtered = filtered.filter(func(question: Question): return !question.is_level_up_queued)
	return filtered

static func matches(question: Question, subject: Subject, options:= {}) -> bool:
	if question == null:
		return false
	return !apply([question], subject, options).is_empty()


static func filter_by_quiz_level(questions: Array, quiz_level: int) -> Array:
	if quiz_level <= 0:
		return questions
	return questions.filter(func(question: Question):
		match quiz_level:
			0, 4, 5, 6:
				return question.level != 3
			1:
				return question.level == 1
			2:
				return question.level == 2
			3:
				return question.level == 3
		return true
	)


static func filter_by_question_types(questions: Array, types: Array) -> Array:
	var clean_types := []
	for type in types:
		var clean_type = str(type).strip_edges()
		if clean_type != "":
			clean_types.push_back(clean_type)
	if clean_types.is_empty():
		return questions
	return questions.filter(func(question: Question):
		for type in clean_types:
			if question.get_attempt_types().has(type):
				return true
		return false
	)


static func filter_by_tags(questions: Array, tags: Array) -> Array:
	var clean_tags := []
	for tag in tags:
		var clean_tag = str(tag).strip_edges().to_lower()
		if clean_tag != "":
			clean_tags.push_back(clean_tag)
	if clean_tags.is_empty():
		return questions
	return questions.filter(func(question: Question):
		var question_tags := []
		for tag in question.tags:
			question_tags.push_back(str(tag).strip_edges().to_lower())
		for clean_tag in clean_tags:
			if !question_tags.has(clean_tag):
				return false
		return true
	)


static func filter_by_parent_ids(questions: Array, subject: Subject, parent_ids: Array, include_ancestors:= true) -> Array:
	var clean_parent_ids := []
	for parent_id in parent_ids:
		var clean_parent_id = int(parent_id)
		if clean_parent_id > 0:
			clean_parent_ids.push_back(clean_parent_id)
	if clean_parent_ids.is_empty() || subject == null:
		return questions
	return questions.filter(func(question: Question):
		for parent_id in clean_parent_ids:
			if !_question_has_parent(question, parent_id, subject, include_ancestors, {}):
				return false
		return true
	)


static func _question_has_parent(question: Question, parent_id: int, subject: Subject, include_ancestors: bool, visited: Dictionary) -> bool:
	if question == null || visited.has(question.id):
		return false
	visited[question.id] = true
	if question.parents.has(parent_id):
		return true
	if !include_ancestors:
		return false
	for direct_parent_id in question.parents:
		var direct_parent = subject.get_question(int(direct_parent_id))
		if direct_parent != null && _question_has_parent(direct_parent, parent_id, subject, true, visited):
			return true
	return false
