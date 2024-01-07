extends Control

signal img_processed

var er
var img

# Called when the node enters the scene tree for the first time.
func _ready():
	$CircleSpin/Spin.play("spin")
	er = $HTTPRequest.request("http://127.0.0.1:3000/datas/")
	if er != OK: print("Oh no")

func tada(type, arr):
	var get_img = Image.new()
	if type == "png":
		get_img.load_png_from_buffer(arr)
	else:
		get_img.load_jpg_from_buffer(arr)
	return get_img

func _on_http_request_request_completed(_result, _response_code, _headers, body):
	var res = JSON.parse_string(body.get_string_from_utf8())
	
	if res == null:
		$Process.text = "Fail..."
		$Result.play("fail")
		await $Result.animation_finished
		await get_tree().create_timer(5).timeout
		return
	$Process.text = "Fetching subjects..."
	for i in res.subjects.keys():
		User.subjects[int(i)] = {
			"title": res.subjects[i]["title"],
			"description": res.subjects[i]["description"]
		}
	$Process.text = "Fetching questions..."
	for i in res.questions.keys():
		$Process.text = "Adding question #{x}".format({"x": i})
		User.questions[int(i)] = {
			"question": res.questions[i]["ask"], 
			"answers": res.questions[i]["answers"],
			"choices": res.questions[i]["choices"], 
			"types": res.questions[i]["types"], 
			"tags": res.questions[i]["tags"], 
			"level": res.questions[i]["level"],
			"subject_id": res.questions[i]["subject"], 
			"hits": 0, 
			"misses": 0, 
			"appearances": 0
		}
		if res.questions[i].has("image"):
			$Process.text = "Adding image for #{x}".format({"x": i})
			print("Question #{x} has image".format({"x": str(i)}))
			print(res.questions[i]["image"])
			if res.questions[i].has("png"):
				$ImageRequest.request(res.questions[i]["image"])
				User.questions[int(i)]["image_format"] = "png"
			else:
				$JPGRequest.request(res.questions[i]["image"])
				User.questions[int(i)]["image_format"] = "jpg"
			await img_processed
			var imoga = Image.new()
			match User.questions[int(i)]["image_format"]:
				"jpg":
					imoga.load_jpg_from_buffer(img)
				"png":
					imoga.load_png_from_buffer(img)
			$Image.texture = ImageTexture.create_from_image(imoga)
			User.questions[int(i)]["image"] = img
	$Process.text = "Saving subjects..."
	var subjects_file = FileAccess.open("user://subjects.dat", FileAccess.WRITE)
	subjects_file.store_var(User.subjects)
	subjects_file.close()
	$Process.text = "Saving questions..."
	var questions_file = FileAccess.open("user://questions.dat", FileAccess.WRITE)
	questions_file.store_var(User.questions)
	questions_file.close()
	$Process.text = "Success!"
	$Result.play("success")
	await $Result.animation_finished
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_image_request_request_completed(_result, _response_code, _headers, body):
	img = body
	emit_signal("img_processed")


func _on_jpg_request_request_completed(_result, _response_code, _headers, body):
	img = body
	emit_signal("img_processed")


func _on_spin_animation_finished(_anim_name):
	$CircleSpin/Spin.play("spin")