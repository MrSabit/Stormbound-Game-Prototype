extends Node


@onready var result_screen := $"../UI/ResultScreen"

func _ready() -> void:
	EventBus.show_result.connect(_on_show_result)
	

func _on_show_result(score_data: Dictionary):
	result_screen.show()
	result_screen.reveal_score(score_data)
	
