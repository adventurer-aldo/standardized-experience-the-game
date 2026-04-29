extends HBoxContainer

var update_timer: Timer


func _ready() -> void:
	update_timer = Timer.new()
	update_timer.one_shot = true
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)
	update_datetime()


func update_datetime() -> void:
	var unix_time = Time.get_unix_time_from_system()
	if Main.data:
		unix_time += Main.data.get_timezone_offset_seconds()
	var date = Time.get_datetime_dict_from_unix_time(unix_time)
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
	var hour = int(date["hour"])
	var minute = str(date["minute"]).lpad(2, "0")
	$Weekday.text = weekday
	$Date.text = "{day}/{month}".format({"month": month, "day": day})
	$Time.text = _format_time(hour, minute)
	_start_next_update_timer(int(date["second"]))


func _format_time(hour: int, minute: String) -> String:
	if Main.data && !Main.data.use_24_hour_time:
		var suffix = "AM" if hour < 12 else "PM"
		var display_hour = hour % 12
		if display_hour == 0:
			display_hour = 12
		return "{hour}:{minute} {suffix}".format({
			"hour": str(display_hour),
			"minute": minute,
			"suffix": suffix,
		})
	return "{hour}:{minute}".format({
		"hour": str(hour).lpad(2, "0"),
		"minute": minute,
	})


func _start_next_update_timer(second: int) -> void:
	update_timer.start(max(1, 60 - second))


func _on_update_timer_timeout() -> void:
	update_datetime()
