@tool
class_name Journey
extends Resource

@export var id:= 0
@export var ost:= "engage"
@export var level := 1
@export var start_time := Time.get_unix_time_from_system()
@export var end_time := 0

func get_chairs():
	var chairs = []
	var path = "user://journeys/" + str(id)
	for file in DirAccess.get_files_at(path):
		chairs.push_back(load(path + "/" + file))
	return chairs
