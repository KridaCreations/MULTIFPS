extends Control

onready var panel_one = $Panel_oneonone
onready var panel_dm = $Panel_deathmatch

func _on_oneononebutton_pressed():
	panel_one.visible = true




func _on_Cancel_pressed():
	panel_one.visible = false
