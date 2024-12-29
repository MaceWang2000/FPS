extends Sprite2D

##输入映射中调用的操作名称
@export var action_name : String
@export var keyboard_icons : Texture2D
@export var input_icon_type: InputIconType

enum InputIconType{
	DYNAMIC,
	KBM
}

var device
var device_index 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_device(InputHelper.device,InputHelper.device_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_input_icon() -> void:
	match input_icon_type:
		InputIconType.DYNAMIC:
			update_input_icon_dynaic()

func update_input_icon_dynaic() -> void:
	match device:
		InputHelper.DEVICE_KEYBOARD:
			update_icon_kbm()
		

func update_icon_kbm() -> void:
	set_texture(keyboard_icons)
	
	var keyboard_input = InputHelper.get_keyboard_inputs_for_action(action_name)
	if keyboard_input is InputEventKey:
		frame = keycode_to_frame_index(OS.get_keycode_string(keyboard_input.keycode))
	else:
		print("DynamicInputIcon: Action=", action_name, ". No primary keyboard/mouse input map assigned.")
		frame = 0
		return

func update_device(_device, _device_index):
	device = _device
	device_index = _device_index
	
	update_input_icon.call_deferred()

func keycode_to_frame_index(key_code_string: String) -> int:
	match key_code_string:
		null:
			return 0
		"Mouse Left":
			return 108
		"Mouse Right":
			return 109
		"Mouse Middle":
			return 110
		"0":
			return 1
		"1":
			return 2
		"2":
			return 3
		"3":
			return 4
		"4":
			return 5
		"5":
			return 6
		"6":
			return 7
		"7":
			return 8
		"8":
			return 9
		"9":
			return 10
		"A":
			return 12
		"B":
			return 13
		"C":
			return 14
		"D":
			return 15
		"E":
			return 16
		"F":
			return 17
		"G":
			return 18
		"H":
			return 19
		"I":
			return 20
		"J":
			return 21
		"K":
			return 22
		"L":
			return 23
		"M":
			return 24
		"N":
			return 25
		"O":
			return 26
		"P":
			return 27
		"Q":
			return 28
		"R":
			return 29
		"S":
			return 30
		"T":
			return 31
		"U":
			return 32
		"V":
			return 33
		"W":
			return 34
		"X":
			return 35
		"Y":
			return 36
		"Z":
			return 37
		"~":
			return 38
		"'":
			return 39
		"<":
			return 40
		">":
			return 41
		"[":
			return 42
		"]":
			return 43
		".":
			return 44
		":":
			return 45
		",":
			return 46
		";":
			return 47
		"=":
			return 48
		"+":
			return 49
		"-":
			return 50
		"^":
			return 51
		"\"":
			return 52
		"?":
			return 53
		"!":
			return 54
		"*":
			return 55
		"/":
			return 56
		"\\":
			return 57
		"Escape":
			return 60
		"Ctrl":
			return 61
		"Alt":
			return 62
		"Space":
			return 63
		"Tab":
			return 64
		"Enter":
			return 65
		"Shift":
			return 66
		
		_:
			return -1
