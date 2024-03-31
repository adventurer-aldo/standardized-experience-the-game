extends ColorRect

func _ready():
	print(Time.get_unix_time_from_system())
	print(load("res://22.res").scheduled_time < Time.get_unix_time_from_system())
