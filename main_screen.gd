extends Control

func _ready():
	pass
		


func _on_Button_pressed():
	var err = (Client.client.connect_to_url("ws://" + $Ip_adress.text))
	print(err)
	if err != OK:
		print("unable to connect")
	else:
		Client.connected = true
		Client.data["id"] = $no.value
		get_tree().change_scene("res://world.tscn")
