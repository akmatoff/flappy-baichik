extends Area2D

signal hit
signal pass_pipe

func _on_body_entered(_body: Node2D) -> void:
	hit.emit()


func _on_score_area_body_entered(_body: Node2D) -> void:
	pass_pipe.emit()
