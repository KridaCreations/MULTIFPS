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

onready var guns = $guns

export var gun_data = {
	"sniper":[
		Vector3(42.513,1.866,-0.903),
		Vector3(38.282,1.866,2.958),
		Vector3(-38.487,1.866,-0.903),
		Vector3(-42.178,1.866,2.958)
	],
	"ak47":[
		Vector3(42.354,1.501,-3.305),
		Vector3(38.442,1.501,5.364),
		Vector3(-38.646,1.501,-3.309),
		Vector3(-42.558,1.501,5.364)
	],
	"pistol":[
		Vector3(42.282,2.046,2.238),
		Vector3(38.513,2.046,-0.183),
		Vector3(-38.718,2.046,2.238),
		Vector3(-42.487,2.046,-0.183)
	],
	"shotgun":[
		Vector3(42.372,1.868,5.364),
		Vector3(38.423,1.868,-3.309),
		Vector3(-38.628,1.868,5.364),
		Vector3(-42.577,1.868,-3.304)
	]
}
var match_started = false
onready var bullet_model = preload("res://Assets/bullet.tscn")

func _ready():
	reload_guns()

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

func start_game(pos):
	if pos == 1:
		$player.global_transform.origin = $first_player.global_transform.origin
	elif pos == 2:
		$player.global_transform.origin = $second_player.global_transform.origin
	$"data panel".visible = true
	$player.reset_player_gun()
	$match_score.visible = false
	match_started = true
	reload_guns()
	pass

func stop_match(info):
	$match_score.visible = true
	print(info)
	if info["data"]["shooter"] == Client.data["id"]:
		$match_score.get_node("info").text = "you killed "+str(info["data"]["dead"])
	elif info["data"]["dead"] == Client.data["id"]:
		$match_score.get_node("info").text = "you get killed by "+str(info["data"]["shooter"])
	else:
		$match_score.get_node("info").text = str(info["data"]["shooter"]) + " killed " + str(info["data"]["dead"])
	var c = 0
	for i in info["score"]:
		$match_score/score_box.get_children()[c].get_node("id").text = str(i)
		$match_score/score_box.get_children()[c].get_node("score").text = str(info["score"][i])
		c += 1
	pass

func reload_scene(pos):
	if pos == 1:
		$player.global_transform.origin = $first_player.global_transform.origin
	elif pos == 2:
		$player.global_transform.origin = $second_player.global_transform.origin
	$player.reset_player_gun()
	$match_score.visible = false
	match_started = true
	reload_guns()
	
	pass
	
func reload_guns():
	for i in guns.get_children():
		i.free()
	
	for gun in gun_data:
		var c = 0
		for pos in gun_data[gun]:
			var new_gun = drop_gun_models[gun].instance()
			guns.add_child(new_gun)
			new_gun.name = gun + str(c)
			new_gun.global_transform.origin = pos
			c+=1
