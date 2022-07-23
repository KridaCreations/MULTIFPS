extends Spatial

export var type:String
export var damage:int
export var max_ammo:int
export var current_ammo:int
export var cooldown_time:float
onready var a_player = $animation
onready var timer = $Timer
export var recoil_value:float

onready var parent = get_parent().get_parent().get_parent().get_parent()
onready var world = get_parent().get_parent().get_parent().get_parent().get_parent()

var die = false

func disappear_and_del():
	a_player.play("disappear")
	die = true
	

func appear():
	a_player.play("appear")
	pass
	
func disappear():
	a_player.play("disappear")
	pass

func reload():
	a_player.play("reload")

func shoot(target_point):
	if timer.is_stopped() == true:# and a_player.is_playing() == false:
		if get_parent().get_parent().get_parent().get_parent().name == "player":
			get_parent().get_parent().get_parent().get_node("AnimationPlayer").play(type+"_recoil")
		timer.start(cooldown_time)
		if type == "sniper":
			shoot_sniper(target_point)
		elif type == "ak47":
			shoot_ak47(target_point)
		elif type == "pistol":
			shoot_pistol(target_point)
		elif type == "shotgun":
			shoot_shotgun(target_point)
		
func shoot_sniper(target_point):
	add_bullet(target_point)
	a_player.play("recoil")	
	pass

func shoot_ak47(target_point):
	
	add_bullet(target_point)
	a_player.play("recoil")
	pass

func shoot_pistol(target_point):
	
	add_bullet(target_point)
	a_player.play("recoil")
	pass

func shoot_shotgun(target_point):
	add_bullet(target_point)
	a_player.play("recoil")
	pass

func add_bullet(target_point):
	var bullet_instance = world.bullet_model.instance()
#	var start_point = $front.global_transform.origin
	var start_point = get_parent().get_parent().get_node("Camera").get_node("bullet_Apawn").global_transform.origin
	bullet_instance.parent = world.get_node("player")
	world.add_child(bullet_instance)
	bullet_instance.p_id = Client.data["id"]
	bullet_instance.connect_signals_for_damage()
	bullet_instance.global_transform.origin = start_point
	bullet_instance.direction = (target_point - start_point).normalized()
	bullet_instance.look_at(target_point,Vector3.UP)
	var message = {
		"mes":"bullet_shot",
		"info":{
			"id":Client.data["id"],
			"start_point":{
				"x":start_point.x,
				"y":start_point.y,
				"z":start_point.z
				},
			"direction":{
				"x":bullet_instance.direction.x,
				"y":bullet_instance.direction.y,
				"z":bullet_instance.direction.z
			},
			"target_point":{
				"x":target_point.x,
				"y":target_point.y,
				"z":target_point.z
			}
		}
	}
	Client.send(message)


func _on_animation_animation_finished(anim_name):
	if anim_name == "reload":
		current_ammo = max_ammo
	if anim_name == "disappear":
		if die == true:
			queue_free()
		
		
