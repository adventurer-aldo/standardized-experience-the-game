extends ColorRect

func _ready():
	var e = [4,3,2,1,5]
	print(e)
	e.sort_custom(func e(a, b):
		return a < b)
	print(e)
