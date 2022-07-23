extends Spatial

onready var data_panel = get_node("data panel")
onready var hand_gun_models = {
	"ak47":preload("res://Assets/weapon_hand/ak47_hand.tscn"),
	"shotgun":preload("res://Assets/weapon_hand/shotgun.tscn"),
	"pistol":preload("res://Assets/weapon_hand/pistol.tscn"),
	"sniper":preload("res://Assets/weapon_hand/sniper.tscn")
}

onready var drop_gun_models = {
	"ak47":preload("res://Assets/weapon_drop/ak47.tscn"),
	"shotgun":preload("res://Assets/weapon_drop/shotgun.tscn"),
	"pistol":preload("res://Assets/weapon_drop/pistol.tscn"),
	"sniper":preload("res://Assets/weapon_drop/sniper.tscn")
}

onready var bullet_model = preload("res://Assets/bullet.tscn")



func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_node("data panel").ready_client(Client.data["id"])
		var message = {
			"mes" :"client_ready",
			"id":Client.data["id"],
			"info":{
				"id":Client.data["id"]
			}
		}
		Client.send(message)

func start_count():
	get_node("data panel/Timer").start()
	get_node("data panel").count = 3
