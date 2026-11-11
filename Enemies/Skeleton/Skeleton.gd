extends KinematicBody2D

const HitEffect = preload("res://Effects/HitEffect.tscn")
const BloodEffect = preload("res://Effects/BloodAndGore/BloodSplash.tscn")
const SoundEffectWalk = preload("res://Enemies/Skeleton/SkeletonWalking.wav")
const SoundEffectAttack1 = preload("res://Enemies/Skeleton/SkeletonAttack1.wav")
const SoundEffectAttack2 = preload("res://Enemies/Skeleton/SkeletonAttack2.wav")
const SoundEffectDeath = preload("res://Enemies/Skeleton/SkeletonDeath.wav")
const Coin = preload("res://Items/Coin/Coin.tscn")
const DeathEffect = preload("res://Effects/EnemyDeathExplosion.tscn")
const HurtEffect = preload("res://Effects/BloodAndGore/SkeletonHitParticle.png")

onready var line = $Line2D
onready var sprite =$Sprite
onready var animationPlayer = $AnimationPlayer

export var health = 5
var target = null
var speed = 32
var knockback = Vector2.ZERO
var obelisk = null
var velocity = Vector2.ZERO

#Pathfinding
var path: Array = []
var levelNavigation = null

enum{
	MOVE,
	ATTACK,
	DEATH,
	HURT
}
var state = MOVE

func _ready():
	yield(get_tree(),"idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Obelisk"):
		obelisk = tree.get_nodes_in_group("Obelisk")[0]
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	randomize()

var attacking = false
func _physics_process(delta):
	match state:
		ATTACK:
			if target != null:
				knockback = knockback.move_toward(Vector2.ZERO, 500*delta)
				move_and_slide(knockback)
				if str(target) != "[Deleted Object]" and !attacking and !Global.enginePause:
					if target.global_position.x < $Hurtbox.global_position.x:
						$Hitbox.knockback_vector2 = Vector2.LEFT
						sprite.flip_h = true
						$Sprite.position.x = -20.3
						$Hitbox.position.x = -25.9
						$Hitbox/CollisionShape2D.rotation_degrees = 45
					else:
						$Hitbox.knockback_vector2 = Vector2.RIGHT
						sprite.flip_h = false
						$Sprite.position.x = 0
						$Hitbox.position.x = 5
						$Hitbox/CollisionShape2D.rotation_degrees = -45
				if knockback.is_equal_approx(Vector2(0,0)):
					animationPlayer.play("Attack")
				else:
					animationPlayer.play("Hit")
		DEATH:
			knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
			move_and_slide(speed * delta * knockback)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			animationPlayer.play("Death")
		MOVE:
			#line.global_position = Vector2.ZERO
			if obelisk and levelNavigation:
				generate_path()
				navigate()
				sprite.flip_h = velocity.x < 0
				if velocity.x < 0:
					$Sprite.position.x = -20.3
				else:
					$Sprite.position.x = 0
				knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
				if knockback.is_equal_approx(Vector2(0,0)):
					move_and_collide(velocity * speed * delta)
					animationPlayer.play("Walk")
				else:
					move_and_slide(knockback)
					animationPlayer.play("Hit")

var inRange = false
func _on_AttackRange_area_entered(area):
	inRange = true
	if area.name == "Location":
		target = area
	elif area.name == "Hurtbox":
		target = area
	if !death:
		state = ATTACK


func _on_AttackRange_area_exited(area):
	inRange = false
	$AttackRange.set_deferred("monitoring", false)
	$AttackRange.set_deferred("monitoring", true)

var death = false
var randomNumber = 0
func _on_Hurtbox_area_entered(area):
	randomNumber = randi() % 4
	if randomNumber == 0:
		$Hurt.pitch_scale = 0.57
	elif randomNumber == 1:
		$Hurt.pitch_scale = 0.7
	elif randomNumber == 2:
		$Hurt.pitch_scale = 0.65
	elif randomNumber == 3:
		$Hurt.pitch_scale = 0.6
	$Hurt.play(0.0)
	var hitEffect = HitEffect.instance()
	get_parent().add_child(hitEffect)
	hitEffect.global_position = $Sprite.global_position
	hitEffect.z_index = 1
	var bloodEffect = BloodEffect.instance()
	bloodEffect.noSound()
	get_parent().add_child(bloodEffect)
	bloodEffect.modulate = Color("ffffff")
	bloodEffect.material = null
	var hurtEffect = HurtEffect
	bloodEffect.texture = hurtEffect
	bloodEffect.global_position = $Sprite.global_position
	bloodEffect.z_index = 1
	

	health -= area.damage
	if health <=0:
		on_death()
		death = true
	knockback = area.knockback_vector * 115


func notInRange():
	attacking = false
	if !inRange and !death:
		state = MOVE

func attack():
	attacking = true

func on_death():
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	state = DEATH

var randomNumber2 = 0
func pitchChange():
	randomNumber2 = randi() % 4
	if randomNumber2 == 0:
		$AudioStreamPlayer2D.set_stream(SoundEffectAttack2)
		$AudioStreamPlayer2D.pitch_scale = 0.9
	elif randomNumber2 == 1:
		$AudioStreamPlayer2D.set_stream(SoundEffectAttack1)
		$AudioStreamPlayer2D.pitch_scale = 0.8
	elif randomNumber2 == 2:
		$AudioStreamPlayer2D.set_stream(SoundEffectAttack2)
		$AudioStreamPlayer2D.pitch_scale = 0.7
	else:
		$AudioStreamPlayer2D.set_stream(SoundEffectAttack1)
		$AudioStreamPlayer2D.pitch_scale = 1

func pitchChangeWalk():
	$AudioStreamPlayer2D.set_stream(SoundEffectWalk)
	randomNumber2 = randi() % 4
	if randomNumber2 == 0:
		$AudioStreamPlayer2D.pitch_scale = 0.9
	elif randomNumber2 == 1:
		$AudioStreamPlayer2D.pitch_scale = 0.8
	elif randomNumber2 == 2:
		$AudioStreamPlayer2D.pitch_scale = 0.7
	else:
		$AudioStreamPlayer2D.pitch_scale = 1

func shadowDeath():
	$Shadow.visible = false
	$ShadowDeath.visible = true


func pitchChangeDeath():
	$AudioStreamPlayer2D.set_stream(SoundEffectDeath)
	randomNumber2 = randi() % 4
	if randomNumber2 == 0:
		$AudioStreamPlayer2D.set_stream(SoundEffectDeath)
		$AudioStreamPlayer2D.pitch_scale = 1
	elif randomNumber2 == 1:
		$AudioStreamPlayer2D.set_stream(SoundEffectDeath)
		$AudioStreamPlayer2D.pitch_scale = 1.1
	elif randomNumber2 == 2:
		$AudioStreamPlayer2D.set_stream(SoundEffectDeath)
		$AudioStreamPlayer2D.pitch_scale = 1.2
	else:
		$AudioStreamPlayer2D.set_stream(SoundEffectDeath)
		$AudioStreamPlayer2D.pitch_scale = 1.3

onready var positionCoin = $Shadow.global_position
func death():
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = $Shadow.global_position
	deathEffect.z_index = 1
	randomNumber = randi()%3
	
	if randomNumber == 0 or randomNumber == 1:
		var coin = Coin.instance()
		get_parent().add_child(coin)
		coin.global_position = $Shadow.global_position
	if randomNumber == 0:
		var coin2 = Coin.instance()
		get_parent().call_deferred("add_child", coin2)
		positionCoin = $CollisionShape2D.global_position
		positionCoin.x -=4
		positionCoin.y -=2
		coin2.global_position = positionCoin
	queue_free()

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
	else:
		if get_tree().has_group("Player"):
			obelisk = get_tree().get_nodes_in_group("Player")[0]
