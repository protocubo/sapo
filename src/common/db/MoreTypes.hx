package common.db;

#if macro
import haxe.macro.Expr;
using StringTools;
using haxe.macro.ExprTools;
#end

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

#if macro
	static function resolveMagicNames(e:Expr)
	{
		return switch e.expr {
		case EConst(CIdent("$second")):
			macro @:pos(e.pos) 1e3;
		case EConst(CIdent("$minute")):
			macro @:pos(e.pos) 6*1e4;
		case EConst(CIdent("$hour")):
			macro @:pos(e.pos) 3.6*1e6;
		case EConst(CIdent("$day")):
			macro @:pos(e.pos) 8.64*1e7;
		case other:
			e.map(resolveMagicNames);
		}
	}
#end

	public macro function delta(ethis:Expr, ms:Expr)
	{
		var p = haxe.macro.Context.currentPos();
		ms = ms.map(resolveMagicNames);
		return macro @:pos(p) (($ethis:Float)+($ms):HaxeTimestamp);
	}

	@:to public function getTime():Float
		return this;

#if tink_template
	@:to public function toHtml():tink.template.Html
		return DateTools.format(toDate(), "%d/%m/%Y %H:%M");
#end
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

