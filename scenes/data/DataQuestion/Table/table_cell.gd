extends TextEdit

@export var editable_stylebox: StyleBoxFlat
@export var normal_stylebox: StyleBoxFlat
@export var is_open:= false

func _ready() -> void:
	if is_open == true:
		flip_open()

func flip_open() -> void:
	set_openness(!is_open)

func set_openness(openness: bool) -> void:
	is_open = openness
	if openness:
		$Background.add_theme_stylebox_override("panel", editable_stylebox)
	else:
		$Background.add_theme_stylebox_override("panel", normal_stylebox)
	
