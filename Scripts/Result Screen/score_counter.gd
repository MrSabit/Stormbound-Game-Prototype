extends Control


@onready var ind_score_container := $VBoxContainer/IndvidualScores/IndScoreContainer
@onready var total_score_container := $VBoxContainer/TotalScore/TotalScoreContainer

@export var score_print_speed := 0.01

@export var score_dist : Dictionary[Data.ObjectiveRole , int]
@export var objective_role_names :Dictionary[Data.ObjectiveRole , String]

var total_score_label : Label

func reveal_score(scores_data : Dictionary):
	for child in ind_score_container.get_children():
		child.queue_free()
	for child in total_score_container.get_children():
		child.queue_free()
		
	var score_labels := _create_score_labels()
	var total_score := 0
	
	#Individual Scores
	for objective_role in scores_data.keys():
		var score = scores_data[objective_role] * score_dist[objective_role]
		_update_score_label(objective_role_names[objective_role], score_labels[objective_role], score)
		
		var wait_time = min(score * score_print_speed , 1.5)
		total_score += score
		await get_tree().create_timer(wait_time).timeout
	
	#Total Score
	_update_score_label("Total Score", total_score_label, total_score)

func _create_score_labels() -> Dictionary:
	var score_labels : Dictionary
	
	#Individual Scores
	for objective_role in Data.ObjectiveRole.values():
		var label = Label.new()
		label.text = objective_role_names[objective_role] + ' : ' + '0'
		ind_score_container.add_child(label)
		score_labels[objective_role] = label
	
	#Total Score
	total_score_label = Label.new()
	total_score_label.text = "Total Score : " + '0'
	total_score_container.add_child(total_score_label)
	return score_labels

func _update_score_label(objective_role_name,label: Label, score: int) -> void:
	var tween = create_tween()
	tween.tween_method(func(value):
		var score_text = str(value)
		label.text = objective_role_name + ' : ' + score_text
		,
		 0, score, min(score_print_speed * score , 1.5)
		)
