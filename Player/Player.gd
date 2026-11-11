extends KinematicBody2D

var ACCELERATION = 500 setget set_acceleration
var FRICTION = 400 setget set_friction
var DASH_MAX_SPEED = 130 setget set_dash_speed
var MAX_SPEED = 90 setget set_max_speed

func set_acceleration(value):
	ACCELERATION = value

func set_friction(value):
	FRICTION = value

func set_dash_speed(value):
	DASH_MAX_SPEED = value

func set_max_speed(value):
	MAX_SPEED = value

const playerWithPistols = preload("res://Player/PlayerWithPistols.png")
const playerWithShotgun = preload("res://Player/PlayerWithShotgun.png")

const bullet = preload("res://Player/Weapons/Bullet.tscn")
const shotgunPellet = preload("res://Player/Weapons/ShotgunPellet.tscn")
const HitEffect = preload("res://Effects/HitEffect.tscn")
const MoonTransformation = preload("res://Player/MoonTransformation/MoonTransformation.tscn")
const ShotgunSmoke = preload("res://Player/Weapons/ShotgunSplash.tscn")

var screen_size = Vector2()
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var attack_vector = Vector2.DOWN
var knockback = Vector2.ZERO
var stats = PlayerStats
var ammoName = "Bullet"

onready var gun1Position = $Position2D
onready var gun2Position = $Position2D2
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $PlayerSprite
onready var sMaterial = CanvasItemMaterial.new()
onready var hurtBox = $Hurtbox
onready var ammoType = bullet
#STATES
enum {
	MOVE,
	ROLL,
	ATTACK,
	TRANSFORM,
	CASTING
}
var state = MOVE

#Timer
var switch = true
var timer = null
var timerHurt = null
var bullet_delay = 0.4
var hurt_delay = 0.5
var can_shoot = true
var can_shoot2 = false
var can_hurt = true
var transforming = false

var randomizer = RandomNumberGenerator.new()
# Start
func _ready():
	ACCELERATION = PlayerStats.acceleration
	FRICTION = PlayerStats.friction
	MAX_SPEED = PlayerStats.max_speed
	DASH_MAX_SPEED = PlayerStats.dash_speed
	randomize()
	randomizer.randomize()
	sprite.visible = true
	$Shadow.visible = true
	$MoonShadow.visible = false
	$Sprite.visible = false
	$Orb.visible = false
	$OrbArea/CollisionShape2D.set_deferred("disabled", true)
	stats.connect("dash_speed_changed", self, "set_dash_speed")
	stats.connect("max_speed_changed", self, "set_max_speed")
	stats.connect("acceleration_changed", self, "set_acceleration")
	stats.connect("friction_changed", self, "set_friction")
# warning-ignore:return_value_discarded
	Global.connect("transformationOver", self, "transform")
	stats.connect("no_health", self, "_on_Stats_no_health")
	# Create timer for shoot delay
	timerHurt = Timer.new()
	timerHurt.set_one_shot(true)
	timerHurt.set_wait_time(hurt_delay)
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(bullet_delay)
	timer.connect("timeout", self, "on_timeout_complete")
	timerHurt.connect("timeout", self, "on_timeout_complete_hurt")
	add_child(timer)
	add_child(timerHurt)
	animationTree.active = true
	sMaterial.set_blend_mode(1)

func castOrb():
	can_hurt = true
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	cast(true)

func _physics_process(delta):
	match state:
		TRANSFORM:
			can_hurt = false
			transforming = true
			animationPlayer.playback_speed = 1.5
			animationPlayer.play_backwards("Transform")
		MOVE:
			_move_state(delta)
		ROLL:
			_roll_state(delta)
		ATTACK:
			_attack_state(delta)
		CASTING:
			_casting_state(delta)

# On Timer's timeout complete BULLET SHOOTING
func on_timeout_complete():
	if switch:
		can_shoot = !can_shoot
		can_shoot2 = !can_shoot
		$AudioGunShot.stop()
		$ShotgunShot.stop()
	switch = !switch
	$AudioGunShot.stop()
	$ShotgunReload.stop()
	can_shoot = !can_shoot
	can_shoot2 = !can_shoot

# On Timer's timeout complete PLAYER BEING HIT
func on_timeout_complete_hurt():
	can_hurt = true
	#hurtBox.monitorable = false
	#hurtBox.monitorable = true
	sprite.set_material(null)

var castAnimation = "Cast_Orb_Standing"
func cast(truth):
	can_hurt = true
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	if truth:
		state = CASTING
		if velocity == Vector2.ZERO:
			castAnimation = "Cast_Orb_Standing"
		else:
			castAnimation = "Cast_Orb_Moving"


func _casting_state(delta):
	_move_state(delta)
	$Orb.visible = true
	$OrbPlayer.play("Attack")
	if velocity == Vector2.ZERO and !orbFinishingTruth:
		castAnimation = "Orb_Casting"
	elif !orbFinishingTruth:
		castAnimation = "Orb_Casting_Moving"
	animationState.travel(castAnimation)


var orbFinishingTruth = false
func orbFinishing():
	orbFinishingTruth = true
	if velocity == Vector2.ZERO:
		castAnimation = "End_Orb_Casting"
	else:
		castAnimation = "End_Orb_Casting_Moving"

func toMoveState():
	state = MOVE

func orbHeightChange():
	$Orb.position.y = -40

func orbFinished():
	$Orb.visible = false
	$Orb.position.y = -20
	orbFinishingTruth = false

func _move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		attack_vector = input_vector
		animationTree.set("parameters/Dash/BlendSpace2D/blend_position", input_vector)
		animationTree.set("parameters/Running/BlendSpace2D/blend_position", input_vector)
		animationState.travel("Running")
		if Global.enginePause:
			velocity = velocity.move_toward(input_vector * MAX_SPEED * 100 , ACCELERATION * 10000 * delta)
		else:
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		if Global.enginePause:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 10000* delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move(delta)
	if Input.is_key_pressed(KEY_SPACE) and state != CASTING:
		$AudioHit.play(0.0)
		can_hurt = false
		state = ROLL
	elif Input.is_action_pressed("ui_shoot_left") and state != CASTING:
		state = ATTACK

func _attack_state(delta):
	if Input.is_action_pressed("ui_shoot_left"):
		shoot(delta, get_local_mouse_position())
	else:
		state = MOVE

var randomPitch = 0
var shotgunShotZIndex = 1
func shoot(delta, direction):
	if timeIsStopped:
		velocity = velocity * 1
	else:
		velocity = velocity * 0.95
	_move_state(delta)
	
	var position = self.get_global_position()
	var pointingDirection = (get_global_mouse_position()-position).normalized()
	var angle = 90 - rad2deg(pointingDirection.angle())
	var animation = "Move_Shoot_Left"
	if angle >=45 and angle <= 135:
		animation = "Move_Shoot_Right"
		gun1Position.position.x = 8
		gun1Position.position.y = -6
		gun2Position.position.x = 7
		gun2Position.position.y = -5
		shotgunShotZIndex = 1
		
	elif angle > 135 and angle <= 225:
		animation = "Move_Shoot_Up"
		gun1Position.position.x = 2
		gun1Position.position.y = -6
		gun2Position.position.x = -2
		gun2Position.position.y = -6
		shotgunShotZIndex = 0
	elif (angle > 225 and angle <=270) or (angle >= -90 and angle <= -45):
		animation = "Move_Shoot_Left"
		gun1Position.position.x = -8
		gun1Position.position.y = -6
		gun2Position.position.x = -7
		gun2Position.position.y = -5
		shotgunShotZIndex = 1
	elif (angle >-45 and angle <=0 ) or (angle >=0 and angle < 45):
		animation = "Move_Shoot_Down"
		gun1Position.position.x = 2
		gun1Position.position.y = -3
		gun2Position.position.x = -2
		gun2Position.position.y = -3
		shotgunShotZIndex = 1

	if velocity == Vector2.ZERO:
		if animation == "Move_Shoot_Right":
			animationState.travel("Shoot_Both_Right")
		elif animation == "Move_Shoot_Left":
			animationState.travel("Shoot_Both_Left")
		elif animation == "Move_Shoot_Down":
			animationState.travel("Shoot_Both_Down")
		else:
			animationState.travel("Shoot_Both_Up")
	else:
		if animation != null:
			animationState.travel(animation)
		else:
			animationState.travel("Move_Shoot_Left")
	randomPitch = randomizer.randi_range(8,12)
	var pitchScale:float = float(randomPitch) / 10
	$AudioGunShot.pitch_scale = pitchScale
	$ShotgunShot.pitch_scale = pitchScale
	$ShotgunReload.pitch_scale = pitchScale
	if can_shoot2:
		can_shoot2 = false
		timer.start()
		if ammoName == "Bullet":
			$AudioGunShot.play(0.0)
			var fire2 = ammoType.instance()
			get_parent().add_child(fire2)
			fire2._set_fireball_directionH(direction)
			fire2.knockback_vector = direction.normalized()
			fire2.position = gun2Position.global_position
		elif ammoName == "Pellet":
			$ShotgunShot.play(0.0)
			var shotgunSmoke = ShotgunSmoke.instance()
			get_parent().add_child(shotgunSmoke)
			shotgunSmoke.rotation = direction.angle()
			shotgunSmoke.global_position = gun1Position.global_position
			shotgunSmoke.z_index = shotgunShotZIndex
			for pellet in range(3):
				var fire2 = ammoType.instance()
				var spread_angle = rand_range(-15, 15)
				fire2._set_fireball_directionH(direction.rotated(deg2rad(spread_angle)))
				fire2.position = gun1Position.global_position
				fire2.knockback_vector = direction.rotated(deg2rad(spread_angle)).normalized()
				get_parent().add_child(fire2)
				
	elif can_shoot:
		timer.start()
		can_shoot = false
		if ammoName == "Bullet":
			$AudioGunShot.play(0.0)
			var fire = ammoType.instance()
			fire._set_fireball_directionH(direction)
			fire.position = gun1Position.global_position
			fire.knockback_vector = direction.normalized()
			get_parent().add_child(fire)
		elif ammoName == "Pellet":
			$ShotgunReload.play(0.0)

func _on_Stats_no_health():
	queue_free()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://GUI/GameOver/GameOver.tscn")

func _roll_state(delta):
	if Global.enginePause:
		velocity = roll_vector * DASH_MAX_SPEED *100
	else:
		velocity = roll_vector * DASH_MAX_SPEED
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	animationState.travel("Dash")
	move(delta)
func _roll_finished():
	velocity = velocity * 0.8
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	if !transforming:
		state = MOVE
		can_hurt = true

func move(delta):
	if Global.velocityAdjusting:
		velocity *= 0.2
		velocity = move_and_slide(velocity)
	elif Global.enginePause and !Global.velocityAdjusting:
		velocity = move_and_slide(velocity)
	else:
		velocity = move_and_slide(velocity)
	knockback = knockback.move_toward(Vector2.ZERO, 500*delta)
	knockback = move_and_slide(knockback)


func _on_Hurtbox_area_entered(area):
	if can_hurt and area.name == "Hitbox":
		stats.hearts -= area.damage
		var hitEffect = HitEffect.instance()
		get_parent().add_child(hitEffect)
		hitEffect.global_position = global_position
		hitEffect.z_index = 1
		hitEffect.offset.y -= 5
		knockback = area.knockback_vector2 * 175
		sprite.set_material(sMaterial)
		can_hurt = false
		timerHurt.start()

# warning-ignore:unused_argument
func _on_ZIndex_area_entered(area):
	Global.zIndex = true


func _on_ZIndex_area_exited(_area):
	Global.zIndex = false

func transform():
	$Transform.play()
	state = TRANSFORM

var timeIsStopped = false
func stopTime():
	$GhostTimer.start()
	timeIsStopped = true
	var multiplier = 100.0
	animationTree.set("parameters/Dash/TimeScale/scale", multiplier)
	animationTree.set("parameters/Running/TimeScale/scale", multiplier)
	animationTree.set("parameters/Idle/TimeScale/scale", multiplier)
	animationTree.set("parameters/Transform/TimeScale/scale", multiplier)
	animationTree.set("parameters/Move_Shoot_Up/TimeScale/scale", multiplier)
	animationTree.set("parameters/Move_Shoot_Right/TimeScale/scale", multiplier)
	animationTree.set("parameters/Move_Shoot_Down/TimeScale/scale", multiplier)
	animationTree.set("parameters/Move_Shoot_Left/TimeScale/scale", multiplier)
	animationTree.set("parameters/Shoot_Both_Right/TimeScale/scale", multiplier)
	animationTree.set("parameters/Shoot_Both_Up/TimeScale/scale", multiplier)
	animationTree.set("parameters/Shoot_Both_Down/TimeScale/scale", multiplier)
	animationTree.set("parameters/Shoot_Both_Left/TimeScale/scale", multiplier)
	animationTree.set("parameters/Cast_Orb_Standing/TimeScale/scale", multiplier)
	animationTree.set("parameters/Orb_Casting/TimeScale/scale", multiplier)
	animationTree.set("parameters/End_Orb_Casting/TimeScale/scale", multiplier)
	animationTree.set("parameters/Cast_Orb_Moving/TimeScale/scale", multiplier)
	animationTree.set("parameters/Orb_Casting_Moving/TimeScale/scale", multiplier)
	animationTree.set("parameters/End_Orb_Casting_Moving/TimeScale/scale", multiplier)
	bullet_delay /= multiplier
	hurt_delay /= multiplier
	timer.set_wait_time(bullet_delay)

func resumeTime():
	$GhostTimer.stop()
	timeIsStopped = false
	var multiplier = 100.0
	animationTree.set("parameters/Dash/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Running/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Idle/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Transform/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Move_Shoot_Up/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Move_Shoot_Right/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Move_Shoot_Down/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Move_Shoot_Left/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Shoot_Both_Right/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Shoot_Both_Up/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Shoot_Both_Down/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Shoot_Both_Left/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Cast_Orb_Standing/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Orb_Casting/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/End_Orb_Casting/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Cast_Orb_Moving/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/Orb_Casting_Moving/TimeScale/scale", multiplier /100)
	animationTree.set("parameters/End_Orb_Casting_Moving/TimeScale/scale", multiplier /100)
	bullet_delay *= multiplier
	hurt_delay *= multiplier
	timerHurt.set_wait_time(hurt_delay)
	timer.set_wait_time(bullet_delay)


func _on_GhostTimer_timeout():
	if timeIsStopped:
		var tempGhost = preload("res://Player/PlayerGhost.tscn").instance()
		get_parent().add_child(tempGhost)
		tempGhost.texture = $PlayerSprite.texture
		tempGhost.vframes = $PlayerSprite.vframes
		tempGhost.hframes = $PlayerSprite.hframes
		tempGhost.frame = $PlayerSprite.frame
		tempGhost.scale = $PlayerSprite.scale
		tempGhost.position = $PlayerSprite.global_position



func _input(event):
	if Input.is_action_pressed("ui_weapon_one"):
		sprite.texture = playerWithPistols
		ammoType = bullet
		ammoName = "Bullet"
	elif Input.is_action_pressed("ui_weapon_two"):
		sprite.texture = playerWithShotgun
		ammoType = shotgunPellet
		ammoName = "Pellet"
	if Input.is_key_pressed(KEY_3):
		Global.canStopTime = false
		Global.canChange = false
		Global.LOrbCanCast = true
		Global.emitSignalItem()
	elif Input.is_key_pressed(KEY_4):
		Global.canStopTime = true
		Global.canChange = false
		Global.LOrbCanCast = false
		Global.emitSignalItem()
	elif Input.is_key_pressed(KEY_5):
		Global.canStopTime = false
		Global.canChange = true
		Global.LOrbCanCast = false
		Global.emitSignalItem()
	elif Input.is_key_pressed(KEY_6):
		PlayerStats.max_speed += 30
		PlayerStats.dash_speed += 20
		PlayerStats.acceleration += 167
		PlayerStats.friction += 134
		PlayerStats.set_dash_speed(PlayerStats.dash_speed)
		PlayerStats.set_max_speed(PlayerStats.max_speed)
		PlayerStats.set_acceleration(PlayerStats.acceleration)
		PlayerStats.set_friction(PlayerStats.friction)
		Global.playerCoins = Global.playerCoins - 0
	elif Input.is_key_pressed(KEY_7):
		PlayerStats.maxHealth += 1
		PlayerStats.hearts +=1
		PlayerStats.set_max_hearts(PlayerStats.maxHealth)
		PlayerStats.set_hearts(PlayerStats.hearts)
