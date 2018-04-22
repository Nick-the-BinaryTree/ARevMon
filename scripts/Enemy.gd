extends Node2D

signal enemy_health_changed
signal enemy_died
signal enemy_message

export var max_health = 30
export var strength = 4
onready var target = $"../Player"

var health = max_health
enum STATES {IDLE, ATTACKING, DEAD}
var state = IDLE

func generate_attack():
	var type = randi() % 4
	var damage = 0
	
	if type == 0: # Occupation
		damage = strength
		emit_signal("enemy_message", "KGIII used Occupation and dealt " + str(damage) + " damage!")
	elif type == 1: # Hessians
		strength += 1
		damage = 2
		emit_signal("enemy_message", "KGIII used Hessians and dealt " + str(damage) + " damage. Received +1 strength.")
	elif type == 2: # Blockade
		damage = strength*1.5 - randi()%strength
		emit_signal("enemy_message", "KGIII used Blockade and dealt " + str(damage) + " damage!")
	else: # Native American Allies
		strength += 1
		damage = randi()%4+1
		emit_signal("enemy_message", "KGIII used Native American Allies and dealt " + str(damage) + " damage. Received +1 strength.")
		
	damage_target(target, damage)
	$AnimationPlayer.play("attack")

func damage_target(target, damage):
	target.take_damage(damage)
	
func take_damage(damage):
	if state == DEAD:
		return
	health -= damage
	if (health < 0):
		state = DEAD
		$AnimationPlayer.play("die")
		emit_signal("enemy_died")
	emit_signal("enemy_health_changed", health)
