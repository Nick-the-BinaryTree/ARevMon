extends Node2D

signal health_changed
signal died
signal player_message

export var max_health = 18
export var strength = 3
onready var target = $"../Enemy"

var health = max_health
enum STATES {IDLE, DEAD, ATTACKING}
var state = IDLE

func generate_attack(type):
	var damage = 0
	if type == 0: # Guerrilla Warfare
		damage = strength*1.5-randi()%strength
		emit_signal("player_message", "GW used Guerrilla Warfare and dealt " + str(damage) + " damage!")
	elif type == 1: # Continental Army
		damage = strength
		emit_signal("player_message", "GW used Continental Army and dealt " + str(damage) + " damage!")
	elif type == 2: # Classical Literature
		strength += 4
		damage = 1
		emit_signal("player_message", "GW used Classical Literature and dealt " + str(damage) + " damage. Received +4 strength.")
	else: # French Allies
		strength += 1
		damage = randi()%10+1
		emit_signal("player_message", "GW used French Allies and dealt " + str(damage) + " damage. Received +1 strength.")
	
	damage_target(target, damage)
	$AnimationPlayer.play("attack")

func damage_target(target, damage):
	target.take_damage(damage)

func take_damage(count):
	if state == DEAD:
		return

	health -= count
	if health <= 0:
		health = 0
		state = DEAD
		$AnimationPlayer.play("die")
		emit_signal("died")

	emit_signal("health_changed", health)
