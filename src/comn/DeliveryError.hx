package comn;

typedef Seconds = Float;

enum DeliveryErrorType {
	E404;
	EBadAuth;
	ERateLimited;
	EOther;
}

class DeliveryError {
	public var type(default,null):DeliveryErrorType;
	public var wait(default,null):Seconds;
	public var error(default,null):Null<Dynamic>;

	public function new(type, wait, error)
	{
		if (type == null) type = EOther;
		if (wait == null) wait = 0.;
		this.type = type;
		this.wait = wait;
		this.error = error;
	}
}

