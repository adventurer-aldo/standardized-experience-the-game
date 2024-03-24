extends ColorRect

func _ready():
	print(Global.get_last_quiz().get_grade())
