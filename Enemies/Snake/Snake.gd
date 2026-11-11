extends KinematicBody2D

onready var sprite =$Sprite
onready var animationPlayer = $AnimationPlayer
onready var line = $Line2D

const Projectile = preload("res://Enemies/Snake/FireBall.tscn")
const BloodEffect = preload("res://Effects/BloodAndGore/BloodSplash.tscn")
const HitEffect = preload("res://Effects/HitEffect.tscn")
const DeathEffect = preload("res://Effects//BloodAndGore/BloodDeath.tscn")
const Coin = preload("res://Items/Coin/Coin.tscn")
const DeathEffectPuff = preload("res://Effects/EnemyDeathExplosion.tscn")

export var health = 5
var target = null
var speed = 5
var knockback = Vector2.ZERO
var obelisk = null
var velocity = Vector2.ZERO
var timer = null
var fence = null
var playerInSight = false
var obeliskInSight = false
var player = null
var isDead = false
var playerInRange = false
var obeliskInRange = false

#Pathfinding
var path: Array = []
var levelNavigation = null

enum{
MOVE,
DEATH,
SHOOT
}
var state = MOVE

func _ready():
	randomize()
	$OnReady.play(0.0)
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.5)
	timer.connect("timeout", self,"on_timeout_complete")
	add_child(timer)
	yield(get_tree(),"idle_frame")
	var tree = get_tree()
	if tree.has_group("Fence"):
		fence = tree.get_nodes_in_group("Fence")[0]
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Obelisk"):
		obelisk = tree.get_nodes_in_group("Obelisk")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

func on_timeout_complete():
	pass

func _physics_process(delta):
	sightCheck()
	match state:
		SHOOT:
			if target != null:
				knockback = knockback.move_toward(Vector2.ZERO, 500*delta)
				knockback = move_and_slide(knockback)
				if knockback.is_equal_approx(Vector2(0,0)):
					sprite.modulate = Color(1, 1, 1)
					animationPlayer.play("Attack")
				else:
					animationPlayer.play("Hit")
					sprite.modulate = Color(1, 0, 0)
				if str(target) != "[Deleted Object]" and !Global.enginePause:
					if target.global_position.x < $Sprite.global_position.x:
						$Position2D.position.x = -41
						$Position2D2.position.x = 19
						sprite.flip_h = true
						$Shadow.position.x = -11
						$Hurtbox/CollisionShape2D2.position.x = 7.5
					else:
						$Position2D.position.x = 19
						$Position2D2.position.x = -41
						sprite.flip_h = false
						$Shadow.position.x = -11
						$Hurtbox/CollisionShape2D2.position.x = -1.5
		DEATH:
			$CollisionShape2D.set_deferred("disabled", true)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$Hurtbox/CollisionShape2D2.set_deferred("disabled", true)
			animationPlayer.play("Death")
		MOVE:
			if playerInSight and playerInRange:
				state = SHOOT
				return
			elif obeliskInSight and obeliskInRange:
				state = SHOOT
				return
			#line.global_position = Vector2.ZERO
			if obelisk and levelNavigation:
				generate_path()
				navigate()
				sprite.flip_h = velocity.x < 0
				if velocity.x < 0:
					$Shadow.position.x = -11
					$Hurtbox/CollisionShape2D2.position.x = 7.5
					$CollisionShape2D.position.x = -9.8
				else:
					$Shadow.position.x = -11
					$Hurtbox/CollisionShape2D2.position.x = -1.5
					$CollisionShape2D.position.x = -12.4
				knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
				if knockback.is_equal_approx(Vector2(0,0)):
					move_and_collide(velocity * speed * delta)
					animationPlayer.play("Move")
					sprite.modulate = Color(1, 1, 1)
				else:
					knockback = move_and_slide(knockback)
					animationPlayer.play("Hit")
					sprite.modulate = Color(1, 0, 0)


func change_speed():
	if speed == 5:
		speed = 45
	elif speed == 45:
		speed = 5

func _on_Hurtbox_area_entered(area):
	$Hurt.play(0.0)
	var hitEffect = HitEffect.instance()
	get_parent().add_child(hitEffect)
	hitEffect.global_position = $Sprite.global_position
	hitEffect.z_index = 1
	var bloodEffect = BloodEffect.instance()
	get_parent().add_child(bloodEffect)
	bloodEffect.global_position = $Sprite.global_position
	bloodEffect.z_index = 1
	health -= area.damage
	knockback = area.knockback_vector * 100
	if health <=0:
		on_death()
		isDead = true

func on_death():
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = sprite.global_position
	deathEffect.z_index = 1
	state = DEATH


var direction
func shoot():
	if str(target) == "[Deleted Object]":
		player = get_tree().get_nodes_in_group("Player")[0]
	if target != null and str(target) != "[Deleted Object]":
		var projectile = Projectile.instance()
		get_parent().add_child(projectile)
		projectile._set_fireball_directionH( target.global_position - $Position2D.global_position )
		projectile.global_position = $Position2D.global_position
	else:
		pass


func _on_AttackRange_area_entered(area):
	if area.name == "ZIndex":
		playerInRange = true
	elif area.name == "Location":
		obeliskInRange = true

func _on_AttackRange_area_exited(area):
	if area.name == "ZIndex":
		playerInRange = false
	elif area.name == "Location":
		obeliskInRange = false

func notInRange():
	if isDead:
		pass
	if !playerInRange or !playerInSight:
		state = MOVE
	if !obeliskInRange or !obeliskInSight:
		state = MOVE

func navigate():
	if path.size() > 0:
		velocity = $CollisionShape2D.global_position.direction_to(path[1])

func generate_path():
	if levelNavigation != null and obelisk != null and str(obelisk) != "[Deleted Object]":
		path = levelNavigation.get_simple_path($CollisionShape2D.global_position, obelisk.global_position, true)
		var local_points = []
		for point in path:
			local_points.append(line.to_local(point))
		line.points = local_points


func sightCheck():
	if str(target) == "[Deleted Object]":
		player = get_tree().get_nodes_in_group("Player")[0]
	if playerInSight and playerInRange:
		target = player
	elif obeliskInRange and obeliskInSight:
		target = obelisk
	if playerInRange:
		var spaceState = get_world_2d().direct_space_state
		var stateCheckPlayer
		var stateCheckPlayer2
		if str(player) != "[Deleted Object]":
			stateCheckPlayer = spaceState.intersect_ray($Position2D.global_position, player.global_position, [self,fence], $LineOfSight.collision_mask)
			stateCheckPlayer2 = spaceState.intersect_ray($Position2D2.global_position, player.global_position, [self,fence], $LineOfSight.collision_mask)
		if stateCheckPlayer and stateCheckPlayer2:
			if (stateCheckPlayer.collider.name == "Player" or stateCheckPlayer.collider.name == "MoonTransformation") and (stateCheckPlayer2.collider.name == "Player" or stateCheckPlayer2.collider.name == "MoonTransformation"):
				playerInSight = true
			else:
				playerInSight = false
	if obeliskInRange:
		var spaceState2 = get_world_2d().direct_space_state
		var stateCheckObelisk = spaceState2.intersect_ray($Position2D.global_position, obelisk.global_position, [self,fence], $LineOfSight.collision_mask)
		if stateCheckObelisk:
			if stateCheckObelisk.collider.name == "Obelisk":
				obeliskInSight = true
			else:
				obeliskInSight = false

var randomNumber = 0
onready var positionCoin = $Shadow.global_position
func death():
	randomNumber = randi()%4
	if randomNumber == 0 or randomNumber == 1 or randomNumber == 2 or randomNumber == 3:
		var coin4 = Coin.instance()
		get_parent().call_deferred("add_child", coin4)
		positionCoin = $Shadow.global_position
		positionCoin.x -=0
		positionCoin.y -=2
		coin4.global_position = positionCoin
	if randomNumber == 1 or randomNumber == 2 or randomNumber == 0:
		var coin = Coin.instance()
		get_parent().call_deferred("add_child", coin)
		coin.global_position = $Shadow.global_position
	if randomNumber == 0 or randomNumber == 1:
		var coin2 = Coin.instance()
		get_parent().call_deferred("add_child", coin2)
		positionCoin = $Shadow.global_position
		positionCoin.x -=4
		positionCoin.y -=2
		coin2.global_position = positionCoin
	if randomNumber == 0:
		var coin3 = Coin.instance()
		get_parent().call_deferred("add_child", coin3)
		positionCoin = $Shadow.global_position
		positionCoin.x +=4
		positionCoin.y -= 2
		coin3.global_position = positionCoin
	var deathEffect = DeathEffectPuff.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = $Shadow.global_position
	deathEffect.z_index = 1
	queue_free()
