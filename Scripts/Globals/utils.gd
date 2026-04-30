extends Node

func terminate(node : Node):
	EventBus.node_terminated.emit(node)
	node.queue_free()
