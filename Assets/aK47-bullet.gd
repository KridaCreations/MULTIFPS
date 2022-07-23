extends Area

var p_id:int
var parent 
var bullet_instance
export var speed : float = 3000.0
var damage : int = 1
var direction = Vector3.ZERO
var bull_char = null
var destroy = 0


func _physics_process(delta):
	var velocity = direction * speed	
	if direction != Vector3.ZERO:
		global_transform.origin += velocity
	

func set_direction(direction : Vector3):
	self.direction = direction
	
func connect_signals_for_damage():
	self.connect("area_entered",self,"_on_bullet_area_entered_damage")
	self.connect("body_entered",self,"_on_bullet_body_entered_damage")
	pass
	

	
func connect_signals():
	self.connect("area_entered",self,"_on_bullet_area_entered")
	self.connect("body_entered",self,"_on_bullet_body_entered")
	pass
	
func _on_bullet_area_entered_damage(area):
	print(area)
	print(area.name)
#	queue_free()


func _on_bullet_body_entered_damage(body):
	print(body)
	print(body.name)
	print("player" in body.name)
	
	if "player" in body.name or "GridMap" in body.name:
		pass
#	else:
#		queue_free()

func _on_bullet_area_entered(area):
	print(area)
	print(area.name)
#	queue_free()


func _on_bullet_body_entered(body):
	
	print(body)
	print(body.name)
	print("player" in body.name)
#	return
	if "player" in body.name or "GridMap" in body.name:
		pass
#		return
#	queue_free()


func _on_Timer_timeout():
	queue_free()
