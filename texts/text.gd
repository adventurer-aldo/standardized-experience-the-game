extends Node

var quiz_results = {
	"defeat": {
		"terrible_voice": split_file_string("quiz_results_defeat_terrible_voice"),
		"tried_voice": split_file_string("quiz_results_defeat_tried_voice"),
		"nice_voice": split_file_string("quiz_results_defeat_nice_voice")
	},
	"victory": {
		"good_voice": split_file_string("quiz_results_victory_good_voice"),
		"great_voice": split_file_string("quiz_results_victory_great_voice"),
		"greatest_voice": split_file_string("quiz_results_victory_greatest_voice"),
		"best_voice": split_file_string("quiz_results_victory_best_voice")
	}
	}
var questions_edit = split_file_string("data_questions_edit")
var start = split_file_string("start_voice")
var quiz = split_file_string("quiz_quiz_voice")
var exit = split_file_string("exit_voice")


func split_file_string(filename: String) -> Array:
	var string = FileAccess.get_file_as_string("res://texts/{filename}.txt".format({"filename": filename}))
	var array = Array(string.split('\n'))
	array.erase("")
	return array
