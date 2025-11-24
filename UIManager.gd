extends Control
@onready var menus:= {
	"paused": $Paused,
	"settings": $Settings
}
var current_menu = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		# toggle between gameplay and pause menu
		if current_menu == null:
			open_menu("paused")
		#else:
		#	close_menus()
		
	var mouse_lock = Input.MOUSE_MODE_VISIBLE if current_menu != null else Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(mouse_lock)

func open_menu(menu_name: String):
	close_menus()
	var menu = menus.get(menu_name) as Control
	if menu:
		menu.visible = true
		current_menu = menu
 
func close_menus():
	for menu in menus.values():
		(menu as Control).visible = false	
	current_menu = null

func quit_game():
	get_tree().quit()
