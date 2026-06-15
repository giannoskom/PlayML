extends Node


var interactible = true

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if interactible:
		if event is InputEventMouseButton:
				if event.pressed:
					interactible = false
					SignalManager.button_train_pressed.emit()
