package sapo.route;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;
#else  // !macro
import common.Dispatch;
import sapo.spod.User;
#end

#if !macro
enum AccessControlError {
	EACNotLoggedIn;
	EACNotAuthorized(?user:User);
	EACSessionExpired(session:Session);
}
#end

@:autoBuild(sapo.route.AccessControl.resolveMetas())
class AccessControl {
	public static inline var META = "authorize";
	public static inline var VAL_ALL = "all";
	public static inline var VAL_GUEST = "guest";
	public static inline var PRIVILEGE = "common.db.MoreTypes.Privilege";

#if macro
	public static function resolveMetas(required=true, verbs=true)
	{
		var vals = switch Context.getType(PRIVILEGE) {
			case TEnum(_.get() => t, _): t.constructs;
			case other: Context.error('Internal: error while searching for Enum type $PRIVILEGE', Context.currentPos());
		}
		var valNames = [ for (n in vals.keys()) n ];
		valNames.push(VAL_ALL);
		valNames.push(VAL_GUEST);

		var prefixes = ["do"];
		if (verbs) prefixes = prefixes.concat(["get", "post"]);

		var fields = Context.getBuildFields();
		for (f in fields) {
			if (Lambda.exists(f.access, function (i) return i.match(AStatic | AMacro)))
				continue;
			for (m in f.meta) {
				switch m.name.split(":") {
				case [META]:
					var params = m.params;
					m.params = [];
					if (params.length == 0)
						Context.warning('Route not authorized to anyone: ${f.name}', f.pos);
					for (p in params) {
						switch p.expr {
						case EConst(CIdent(magic)), EConst(CString(magic)) if (magic == VAL_ALL || magic == VAL_GUEST):
							m.params.push(Context.makeExpr(magic, m.pos));
						case EConst(CIdent(cname)), EConst(CString(cname)):
							if (!vals.exists(cname))
								Context.fatalError('No privilege $cname\nTry one of the following: ${valNames.join(", ")}', m.pos);
							m.params.push(Context.makeExpr(vals.get(cname).index, m.pos));
						case _:
							Context.fatalError('Unsupported @$META value: ${p.toString()}\n' +
									'Use $PRIVILEGE constructors or other special values: ${valNames.join(", ")}', m.pos);
						}
					}
				case [_, META]:
					Context.fatalError('Access control cannot be a compiler metadata\n' +
							'Instead of @${m.name} use @$META', m.pos);
				case _:  // NOOP
				}
			}
			if (required &&
					Lambda.exists(prefixes, function (i) return StringTools.startsWith(f.name, i)) &&
					!Lambda.exists(f.meta, function (i) return i.name == META))
				Context.fatalError('Missing access control meta @$META on route ${f.name}', f.pos);

		}
		return fields;
	}
#else  // !macro
	public static function onDispatchMeta(v:String, params:Null<Array<Dynamic>>)
	{
		switch v {
		case META:
			if (Lambda.exists(params, function (i) return i == VAL_GUEST))
				return;  // NOOP

			// no need to check for params.length == 0, since that has been enforced in macro mode
			var ctx = Context.loop;
			if (ctx.session == null) throw EACNotLoggedIn;
			if (ctx.session.expired()) {
				ctx.session.expire();
				throw EACSessionExpired(ctx.session);
			}
			if (!Lambda.exists(params, function (i:Dynamic) return i == VAL_ALL || i == ctx.privilege.getIndex()))
				throw EACNotAuthorized(ctx.user);
		case _:  // NOOP
		}
	}
#end
}

