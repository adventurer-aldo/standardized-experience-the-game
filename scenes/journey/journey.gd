extends ColorRect

@export var id: int
@export var chair: PackedScene
@export var test: PackedScene
var journey: Journey

func _ready() -> void:
	$SummerSky/AnimationPlayer.play("spin")
	Main.wipe_out()	
	if Main.data.last_journey_id > 0:
		journey = Main.data.get_last_journey()
		for chair_to_add in journey.get_chairs():
			var add_chair = chair.instantiate()
			add_chair.set_title(chair_to_add.get_subject().title)
			$Columns/Chairs.add_child(add_chair)


func _on_button_pressed() -> void:
	var new_journey:= Journey.new()
	new_journey.id = Main.data.next_journey_id()
	new_journey.create()
	get_tree().reload_current_scene()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$SummerSky/AnimationPlayer.play("spin")
