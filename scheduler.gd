extends Node

signal queues_checked

var thr = Thread.new()

func _ready() -> void:
	await Global.subjects_loaded
	check_queues()

func check_queues():
	thr.start(do_thing)

func do_thing():
	for queue in DirAccess.get_files_at("user://queues"):
		load("user://queues/" + queue).check()
	call_deferred("emit_signal", "queues_checked")

func _exit_tree() -> void:
	if thr.is_started(): thr.wait_to_finish()
