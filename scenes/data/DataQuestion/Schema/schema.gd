extends Control


func _on_area_2d_mouse_entered() -> void:
	print("Mouse entered")


func _on_area_2d_mouse_exited() -> void:
	print("Mouse exited")


func _on_button_text_changed() -> void:
	$Button/Area2D/CollisionShape2D.shape.size = $Button.size
	$Button/Area2D.position = Vector2($Button.position.x / 2.0, $Button.position.y / 2.0)
