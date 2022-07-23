extends Control

onready var join_panel = $panel_join




func _on_Join_pressed():
	join_panel.visible = true


func _on_Cancel_pressed():
	join_panel.visible = false


func _on_Host_pressed():
	get_tree().change_scene("res://Assets/scenes/Match_type.tscn")
