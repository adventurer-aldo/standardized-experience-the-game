extends HBoxContainer

func _process(_delta: float) -> void:
	var date = Time.get_datetime_dict_from_system()
	var weekday
	match date["weekday"]:
		0: weekday = "Sun"
		1: weekday = "Mon"
		2: weekday = "Tue"
		3: weekday = "Wed"
		4: weekday = "Thu"
		5: weekday = "Fri"
		6: weekday = "Sat"
	var day = str(date["day"]).lpad(2, "0")
	var month = str(date["month"]).lpad(2, "0")
	var hour = str(date["hour"]).lpad(2, "0")
	var minute = str(date["minute"]).lpad(2, "0")
	$Weekday.text = weekday
	$Date.text = "{month}/{day}".format({"month": month, "day": day})
	$Time.text = "{hour}:{minute}".format({"hour": hour, "minute": minute})
