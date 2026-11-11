extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var hitBox = $Hitbox
onready var line = $Line2D

const BloodEffect = preload("res://Effects/BloodAndGore/BloodSplash.tscn")
const HitEffect = preload("res://Effects/HitEffect.tscn")
const Coin = preload("res://Items/Coin/Coin.tscn")
const DeathEffect = preload("res://Enemies/CrazyDemon/CrazyDemonDeath.tscn")


var knockback = Vector2.ZERO
var speed = 90
var canMove = true
var timer = null
var timer2 = null
var timer3 = null
export var health = 4

#Pathfinding
var path: Array = []
var levelNavigation = null
var player = null
var velocity = Vector2.ZERO
var direction = Vector2.ZERO

signal on_death

func _ready():
	randomize()
	yield(get_tree(),"idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	$GrowlRun.play(0.0)
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(5)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	timer2 = Timer.new()
	timer2.set_one_shot(true)
	timer2.set_wait_time(1.5)
	timer2.connect("timeout", self, "on_timeout_complete2")
	add_child(timer2)
	timer3 = Timer.new()
	timer3.set_one_shot(true)
	timer3.set_wait_time(0.2)
	timer3.connect("timeout", self, "on_timeout_complete3")
	add_child(timer3)
	timer.start()

func on_timeout_complete():
	canMove = false
	timer2.start()

func on_timeout_complete2():
	if !$GrowlRun.playing:
		$GrowlRun.play(0.0)
	canMove = true
	timer.start()

func on_timeout_complete3():
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)

func _physics_process(delta):
	if !Global.enginePause:
		sprite.flip_h = velocity.x < 0
	hitBox.knockback_vector2 = direction
	if canMove:
		#line.global_position = Vector2.ZERO
		if player and levelNavigation:
			generate_path()
			navigate()
			knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
			if knockback.is_equal_approx(Vector2(0,0)):
				move_and_collide(velocity * speed * delta)
				animationPlayer.play("Run")
				$Sprite.modulate = Color(1, 1, 1)
			else:
				move_and_slide(knockback)
				animationPlayer.play("Hit")
				$Sprite.modulate = Color(1, 0, 0)
	else:
		if !knockback.is_equal_approx(Vector2(0,0)):
			knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
			move_and_slide(knockback)
			$Sprite.modulate = Color(1, 0, 0)
			animationPlayer.play("Hit")
		else:
			animationPlayer.play("Idle")
			$Sprite.modulate = Color(1, 1, 1)

func _on_Hurtbox_area_entered(area):
	var hitEffect = HitEffect.instance()
	var bloodEffect = BloodEffect.instance()
	get_parent().add_child(bloodEffect)
	get_parent().add_child(hitEffect)
	hitEffect.global_position = $Sprite.global_position
	hitEffect.z_index = 1
	bloodEffect.global_position = $Sprite.global_position
	bloodEffect.z_index = 1
	health -= area.damage
	if health <=0:
		on_death()
	knockback = area.knockback_vector * 75

var randomNumber = 0
onready var positionCoin = $CollisionShape2D.global_position
func on_death():
	randomNumber = randi()%4
	if randomNumber == 1 or randomNumber == 2 or randomNumber == 0:
		var coin = Coin.instance()
		get_parent().call_deferred("add_child", coin)
		coin.global_position = $CollisionShape2D.global_position
	if randomNumber == 0 or randomNumber == 1:
		var coin2 = Coin.instance()
		get_parent().call_deferred("add_child", coin2)
		positionCoin = $CollisionShape2D.global_position
		positionCoin.x -=4
		positionCoin.y -=2
		coin2.global_position = positionCoin
	if randomNumber == 0:
		var coin3 = Coin.instance()
		get_parent().call_deferred("add_child", coin3)
		positionCoin = $CollisionShape2D.global_position
		positionCoin.x +=4
		positionCoin.y -= 2
		coin3.global_position = positionCoin
	
	var deathEffect = DeathEffect.instance()
	get_parent().call_deferred("add_child", deathEffect)
	deathEffect.global_position = $Sprite.global_position
	deathEffect.z_index = 1
	queue_free()

func _on_Hitbox_area_entered(area):
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	timer3.start()

func navigate():
	if path.size() > 0:
		direction = $CollisionShape2D.global_position.direction_to(path[1])
		velocity = direction

func generate_path():
	if levelNavigation != null and player != null and str(player) != "[Deleted Object]":
		path = levelNavigation.get_simple_path($CollisionShape2D.global_position, player.global_position, true)
		var local_points = []
		for point in path:
			local_points.append(line.to_local(point))
		line.points = local_points
	else:
		if get_tree().has_group("Player"):
			player = get_tree().get_nodes_in_group("Player")[0]
