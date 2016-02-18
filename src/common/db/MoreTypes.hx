package common.db;

abstract HaxeTimestamp(Float) from Float to Float {
	inline function new(t)
		this = t;

	@:to public function toDate():Date
		return Date.fromTime(this);

	@:from public static function fromDate(d:Date)
		return new HaxeTimestamp(d.getTime());

	@:to public function toString():String
		return toDate().toString();

#if tink_template
	@:to public function toHtml():tink.template.Html
		return toDate().toString();
#end
}

enum Privilege {
	PSurveyor;
	PSupervisor;
	PPhoneOperator;
	PSuper;
}

abstract AccessName(String) to String {
	public function new(name)
		this = name;
}

abstract EmailAddress(String) to String {
	public function new(email)
		this = email;
}

