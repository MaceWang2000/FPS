extends Node

#Interaction信号系统
signal interactive_object_detected(interaction_nodes: Array[Node])
signal nothing_detected()
signal started_carrying(interaction_node: Node)

#改变携带状态
signal carry_state_changed(is_being_carried : bool)
signal throw(impulse)
