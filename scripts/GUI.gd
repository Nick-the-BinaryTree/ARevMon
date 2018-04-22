extends MarginContainer

onready var number_label = $Vertical/Bars/LifeBar/Count/Background/Number
onready var bar = $Vertical/Bars/LifeBar/TextureProgress
onready var enemy_bar = $Vertical/Bars/EnemyBar/TextureProgress
onready var a1 = $Vertical/CommandBG/Grid/A1
onready var a2 = $Vertical/CommandBG/Grid/A2
onready var a3 = $Vertical/CommandBG/Grid/A3
onready var a4 = $Vertical/CommandBG/Grid/A4
onready var grid = $Vertical/CommandBG/Grid
onready var msg_box = $Vertical/CommandBG/Message
onready var tween = $Tween
onready var animated_health = 0
onready var enemy_animated_health = 0
onready var white = Color(1, 1, 1, 1)
onready var select_color = Color(.25, .5, .9, 1)
onready var player = $"../Characters/Player"
onready var enemy = $"../Characters/Enemy"

enum STATES {UL, UR, LL, LR, PA, EA, END}
var state = UL


func _ready():
	var player_max_health = player.max_health
	var enemy_max_health = enemy.max_health
	bar.max_value = player_max_health
	enemy_bar.max_value = enemy_max_health
	update_health(player_max_health)
	update_enemy_health(enemy_max_health)
	if not tween.is_active():
		tween.start();

func _process(delta):
	var round_health = round(animated_health)
	number_label.text = str(round_health)
	bar.value = animated_health
	enemy_bar.value = enemy_animated_health

func update_health(new_value):
	tween.interpolate_property(self, "animated_health", animated_health, new_value, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)

func update_enemy_health(new_value):
	tween.interpolate_property(self, "enemy_animated_health", enemy_animated_health, new_value, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)

func _on_Player_health_changed(player_health):
	update_health(player_health)

func _on_Enemy_enemy_health_changed(enemy_health):
	update_enemy_health(enemy_health)
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_RIGHT:
			if state == UL:
				a1.add_color_override("font_color", white)
				a2.add_color_override("font_color", select_color)
				state = UR
			elif state == LL:
				a3.add_color_override("font_color", white)
				a4.add_color_override("font_color", select_color)
				state = LR
		elif event.scancode == KEY_LEFT:
			if state == UR:
				a2.add_color_override("font_color", white)
				a1.add_color_override("font_color", select_color)
				state = UL
			elif state == LR:
				a4.add_color_override("font_color", white)
				a3.add_color_override("font_color", select_color)
				state = LL
		elif event.scancode == KEY_DOWN:
			if state == UL:
				a1.add_color_override("font_color", white)
				a3.add_color_override("font_color", select_color)
				state = LL
			elif state == UR:
				a2.add_color_override("font_color", white)
				a4.add_color_override("font_color", select_color)
				state = LR
		elif event.scancode == KEY_UP:
			if state == LL:
				a3.add_color_override("font_color", white)
				a1.add_color_override("font_color", select_color)
				state = UL
			elif state == LR:
				a4.add_color_override("font_color", white)
				a2.add_color_override("font_color", select_color)
				state = UR
		elif event.scancode == KEY_ENTER:
			if state == END:
				return_to_title()
			elif state == PA:
				state = EA # race condition w/ player death
				enemy.generate_attack()
			elif state == EA:
				grid.show()
				msg_box.hide()
				state = UL
				color_reset()
			else: # player picked attack
				grid.hide()
				msg_box.show()
				var attack = 0
				if state == UR:
					attack = 1
				elif state == LL:
					attack = 2
				elif state == LR:
					attack = 3
				state = PA
				player.generate_attack(attack)
				
func color_reset():
	a1.add_color_override("font_color", select_color)
	a2.add_color_override("font_color", white)
	a3.add_color_override("font_color", white)
	a4.add_color_override("font_color", white)

func return_to_title():
	get_tree().change_scene("res://TitleScreen.tscn")

func _on_Player_player_message(msg):
	msg_box.text = msg

func _on_Enemy_enemy_message(msg):
	msg_box.text = msg

func _on_Player_died():
	msg_box.text = "The governor isn't going to be very happy about this."
	grid.hide()
	msg_box.show()
	state = END

func _on_Enemy_enemy_died():
	msg_box.text = "Freeedooooooom!"
	grid.hide()
	msg_box.show()
	state = END