package common.db;

#if macro
import haxe.macro.Expr;
using StringTools;
using haxe.macro.ExprTools;
#end

abstract HaxeTimestamp(Float) from Float to Float {
	static inline var SECOND = 1e3;
	static inline var MINUTE = 60*SECOND;
	static inline var HOUR = 60*MINUTE;
	static inline var DAY = 24*HOUR;
	static inline var WEEK = 7*DAY;

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

#if macro
	static function matchConstants(e:Expr)
	{
		return switch e.expr {
		case EConst(CIdent(name)) if (name.startsWith("$")):
			var eqName = name.substr(1).toUpperCase();
			macro @:pos(e.pos) @:privateAccess common.db.MoreTypes.HaxeTimestamp.$eqName;
		case other:
			e.map(matchConstants);
		}
	}
#end

	public macro function delta(ethis:Expr, ms:Expr)
	{
		var p = haxe.macro.Context.currentPos();
		ms = matchConstants(ms);
		return macro @:pos(p) (($ethis:Float)+($ms):HaxeTimestamp);
	}

	@:to public function getTime():Float
		return this;

#if tink_template
	@:to public function toHtml():tink.template.Html
		return DateTools.format(toDate(), "%d/%m/%Y %H:%M");
#end

	public static macro function resolveTime(ms:Expr)
	{
		var p = haxe.macro.Context.currentPos();
		ms = matchConstants(ms);
		return macro @:pos(p) $ms;
	}
}

enum Privilege {
	PSurveyor;
	PSupervisor;
	PPhoneOperator;
	PSuperUser;
}

abstract EmailAddress(String) to String {
	public inline function new(email)
		this = email;
}

