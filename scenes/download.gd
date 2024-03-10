extends Control

signal img_processed

var er
var img
var load_size
var host := "localhost"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_size = $Load.size.x
	$Host.text = host

func start():
	$Fade.hide()
	$Process.text = "Connecting..."
	$CircleSpin/Spin.play("spin")
	er = $HTTPRequest.request("http://{host}:3000/datas/".format({"host": host}))

func tada(type, arr):
	var get_img = Image.new()
	if type == "png":
		get_img.load_png_from_buffer(arr)
	else:
		get_img.load_jpg_from_buffer(arr)
	return get_img

func fail():
	$Process.text = "Fail..."
	$Result.play("fail")
	get_tree().create_tween().tween_property($Load/LoadingBar/ParticleControl/CPUParticles2D, "color", Color.RED, 0.1)
	$Load/LoadingBar/ParticleControl/CPUParticles2D.emitting = false
	get_tree().create_tween().tween_property($Progress/Glow, "modulate", Color.RED, 0.1)
	await $Result.animation_finished
	await get_tree().create_timer(5).timeout

func _on_http_request_request_completed(_result, _response_code, _headers, body):
	$Process.text = "Downloading..."
	var res = JSON.parse_string(body.get_string_from_utf8())
	
	if res == null:
		fail()
		return
	$Process.text = "Fetching subjects..."
	var orig_subj = load("res://resources/subject.tres")
	for i in res.subjects.keys():
		var new_subj = orig_subj.duplicate()
		new_subj.id = int(i)
		new_subj.title = res.subjects[i]["title"]
		new_subj.color = generate_random_color_with_contrast()
		new_subj.description = res.subjects[i]["description"]
		if !DirAccess.dir_exists_absolute("user://subjects/{dir}".format({"dir": str(i)})):
			DirAccess.make_dir_absolute("user://subjects/{dir}".format({"dir": str(i)}))
		ResourceSaver.save(new_subj, "user://subjects/{n}.res".format({"n": str(i)}), ResourceSaver.FLAG_COMPRESS)
		$Process.text = "Fetching questions..."
	var orig_quest = load("res://resources/question.tres")
	for i in res.questions.keys():
		$Progress.text = str(int((float(res.questions.keys().find(i) + 1) / float(res.questions.keys().size())) * 100)) + '%'
		#get_tree().create_tween().tween_property($Load/LoadingBar, "size", Vector2((float(res.questions.keys().find(i) + 1) / float(res.questions.keys().size())) * load, $Load/LoadingBar.size.y), 0.1)
		$Load/LoadingBar.size.x = (float(res.questions.keys().find(i) + 1) / float(res.questions.keys().size())) * load_size
		$Process.text = "Adding question #{x}".format({"x": i})
		var new_quest = orig_quest.duplicate()
		new_quest.id = int(i)
		new_quest.question = res.questions[i]["ask"]
		new_quest.answers = res.questions[i]["answers"]
		new_quest.choices = res.questions[i]["choices"]
		new_quest.tags = res.questions[i]["tags"]
		new_quest.level = res.questions[i]["level"]
		new_quest.subject_id = int(res.questions[i]["subject"])
		
		if res.questions[i]["types"].has("open"): new_quest.open = true
		if res.questions[i]["types"].has("choice"): new_quest.choice = true
		if res.questions[i]["types"].has("veracity"): new_quest.veracity = true
		if res.questions[i]["types"].has("fill"): new_quest.fill = true
		if res.questions[i]["types"].has("match"): new_quest.match = true
		if res.questions[i]["types"].has("table"): new_quest.table = true
		if res.questions[i].has("image"):
			$Process.text = "Adding image for #{x}".format({"x": i})
			if res.questions[i].has("png"):
				$ImageRequest.request(res.questions[i]["image"])
			else:
				$JPGRequest.request(res.questions[i]["image"])
			await img_processed
			var imoga = Image.new()
			if res.questions[i].has("png"):
				imoga.load_png_from_buffer(img)
			else:
				imoga.load_jpg_from_buffer(img)
			imoga.compress(Image.COMPRESS_S3TC, 0, Image.ASTC_FORMAT_8x8)
			new_quest.image = imoga
			$Image.texture = ImageTexture.create_from_image(imoga)
		ResourceSaver.save(new_quest, "user://subjects/{subj}/{n}.res".format({"subj": str(new_quest.subject_id), "n": str(i)}), ResourceSaver.FLAG_COMPRESS)
	$Process.text = "Saving questions..."
	$Process.text = "Success!"
	$Result.play("success")
	await $Result.animation_finished
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_image_request_request_completed(result, _response_code, _headers, body):
	if result == null:
		fail()
	else:
		img = body
		emit_signal("img_processed")


func _on_jpg_request_request_completed(result, _response_code, _headers, body):
	if result == null:
		fail()
	else:
		img = body
		emit_signal("img_processed")


func _on_spin_animation_finished(_anim_name):
	$CircleSpin/Spin.play("spin")

func _on_host_text_changed(new_text):
	host = new_text

func _on_go_pressed():
	$Host.hide()
	start()

func generate_random_color_with_contrast():
	var random_color = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))

	# Calculate the luminance of the color
	var luminance = 0.2126 * random_color.r + 0.7152 * random_color.g + 0.0722 * random_color.b

	# Check if the luminance is too bright or too dark
	if luminance > 0.5:
		# If too bright, make the color darker
		random_color.r = random_color.r * 0.7
		random_color.g = random_color.g * 0.7
		random_color.b = random_color.b * 0.7
	else:
		pass
		# If too dark, make the color lighter
		# random_color.r = random_color.r + (1 - random_color.r) * 0.3
		# random_color.g = random_color.g + (1 - random_color.g) * 0.3
		# random_color.b = random_color.b + (1 - random_color.b) * 0.3

	return random_color


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
