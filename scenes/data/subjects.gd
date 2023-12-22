extends Control

var title := ""
var description := ""

func _ready():
	title = $Title.text
	description = $Description.text
	refresh()

func _on_title_text_changed():
	title = $Title.text.strip_edges()

func _on_description_text_changed():
	description = $Description.text.strip_edges()

func refresh():
	for i in $VScrollBar/Questions.get_child_count():
		$VScrollBar/Questions.get_child(i).queue_free()
	for i in User.subjects.keys():
		var subj = $Panel.duplicate()
		subj.get_child(0).text = User.subjects[i].title
		subj.get_child(1).text = User.subjects[i].description
		$VScrollBar/Questions.add_child(subj)
		subj.show()

func _on_submit_pressed():
	if title == "": return
	var key = (User.subjects.keys()[-1] || -1) + 1
	User.subjects[key] = {'title': title, 'description': description}
	$Title.text = ""
	title = ""
	$Description.text = ""
	description = ""
	$Title.grab_focus()
	var file = FileAccess.open("user://subjects.dat", FileAccess.WRITE)
	file.store_var(User.subjects)
	file.close()
	refresh()
