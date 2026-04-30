extends Control


func reveal_score(scores_data):
	%ScoreCounter.reveal_score(scores_data)


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	Data.inventory[3] = [Data.Item.WALL, 7]
