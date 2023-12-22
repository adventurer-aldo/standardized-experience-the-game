extends Control

signal img_processed

var er
var bod
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
		$CircleSpin/Result.play("fail")
		await $CircleSpin/Result.animation_finished
		await get_tree().create_timer(5).timeout
		return
	for i in res.keys():
		User.questions[int(i)] = {
			"question": res[i]["ask"], 
			"answers": res[i]["answers"],
			"choices": res[i]["choices"], 
			"types": res[i]["types"], 
			"tags": res[i]["tags"], 
			"level": res[i]["level"],
			"subject_id": res[i]["subject"], 
			"hits": 0, 
			"misses": 0, 
			"appearances": 0
		}
		if res[i].has("image"):
			print("Has image")
			print(res[i]["image"])
			if res[i].has("png"):
				$ImageRequest.request(res[i]["image"])
				User.questions[int(i)]["image_format"] = "png"
			else:
				$JPGRequest.request(res[i]["image"])
				User.questions[int(i)]["image_format"] = "jpg"
			await img_processed
			User.questions[int(i)]["image"] = img
	var questions_file = FileAccess.open("user://questions.dat", FileAccess.WRITE)
	questions_file.store_var(User.questions)
	questions_file.close()
	$Process.text = "Success!"
	$CircleSpin/Result.play("success")
	await $CircleSpin/Result.animation_finished
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
