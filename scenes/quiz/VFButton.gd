extends Button

var e: int = -1

func _on_pressed():
	e = [-2, -1, 0, 1].find([-1, 0, 1].find(e))
	
