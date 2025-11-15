extends ColorRect

signal finished_dim
signal finished_fade_animation

func dim() -> void:
	$Dim.play("dim")
	await $Dim.animation_finished
	finished_dim.emit()

func undim() -> void:
	$Dim.play("undim")
	await $Dim.animation_finished
	finished_dim.emit()

func fade_in() -> void:
	$SlideFade.play("fade_in")
	await $SlideFade.animation_finished
	finished_fade_animation.emit()

func fade_out() -> void:
	$SlideFade.play("fade_out")
	await $SlideFade.animation_finished
	finished_fade_animation.emit()

func announce_text(text: String) -> void:
	$Banner/Label.text = text
	dim()
	fade_in()

func remove_announcement() -> void:
	undim()
	fade_out()
