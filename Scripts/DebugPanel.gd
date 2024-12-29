extends PanelContainer

@onready var property_container: VBoxContainer = %VBoxContainer

#var property
var frames_second : String

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#设置全局引用
	Global.debug = self
	
	visible = false
	#add_debug_property("FPS", frames_second)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frames_second = "%.2f" % (1.0/delta)
	#property.text = property.name + ":" + frames_second

func _input(event):
	if event.is_action_pressed("debug"):
		visible = not visible

func add_property(title : String, value, order):
	var target
	target  = property_container.find_child(title, true, false)
	if not target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ":" + str(value)
	elif visible:
		target.text = title + ":" + str(value)
		property_container.move_child(target,order)

#func add_debug_property(title : String, value):
	#property = Label.new() #创建新的label
	#property_container.add_child(property) 
	#property.name = title
	#property.text = property.name + value
	#
