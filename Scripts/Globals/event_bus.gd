extends Node

@warning_ignore_start("unused_signal")
# Emits when a house got destroyed
signal building_distoryed

#Emits when results are ready to show
signal show_result(score_data: Dictionary)

#Emits when a disasted is ended
signal disaster_ended

#Emits when inventory item changed
signal update_hotbar

#Emits when a building is added
signal building_added

#Emits when a building is removed
signal building_removed

#Emits signal when a node is terminated or queue freed
signal node_terminated(node : Node)

#Emits when the direction of wind changes
signal wind_direction_changed(dir : Vector3)
