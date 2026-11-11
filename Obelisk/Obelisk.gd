extends StaticBody2D

var stats = ObeliskStats
const HitEffect = preload("res://Effects/HitEffect.tscn")

var timer = null
var delay = 0.5
var check = true

func _ready():
	$AnimatedSprite.play("Animate")
	stats.connect("no_health2", self, "_on_ObeliskStats_no_health2")
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(delay)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
		# Process for Input Event
	set_process_input(true)
	# Process for UI
	set_process(true)

func on_timeout_complete():
	check = true

func _on_Hurtbox_area_entered(area):
	if check and area.name == "Hitbox":
		var hitEffect = HitEffect.instance()
		get_parent().add_child(hitEffect)
		hitEffect.global_position = global_position
		hitEffect.z_index = 1
		hitEffect.offset.y -= 10
		stats.hearts2 -= area.damage
		check = false
		timer.start()

func _on_ObeliskStats_no_health2():
	queue_free()
	get_tree().change_scene("res://GUI/GameOver/GameOver.tscn")

