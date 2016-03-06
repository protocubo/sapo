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

	@:op(A > B) public function gt(rhs:HaxeTimestamp):Bool;
	@:op(A >= B) public function gte(rhs:HaxeTimestamp):Bool;
	@:op(A < B) public function lt(rhs:HaxeTimestamp):Bool;
	@:op(A <= B) public function lte(rhs:HaxeTimestamp):Bool;

#if tink_template
	@:to public function toHtml():tink.template.Html
		return DateTools.format(toDate(), "%d-%m-%Y %H:%M");
#end
}

enum Privilege {
	PSurveyor;
	PSupervisor;
	PPhoneOperator;
	PSuperUser;
}

enum SurveyStatus {
	SSPending;
	SSCompleted;
	SSRefused;
	SSAccepted;
	SSAll;
}

abstract EmailAddress(String) to String {
	public inline function new(email)
		this = email;
}

