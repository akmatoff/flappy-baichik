extends Control

signal restart

func _on_restart_button_pressed() -> void:
	print("restart")
	restart.emit()
