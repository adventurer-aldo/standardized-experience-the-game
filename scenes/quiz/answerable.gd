extends Control

@export var question_id := 777

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = User.questions[question_id].question[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
