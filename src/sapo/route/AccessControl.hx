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
	EACNotAuthorized(?user:User);
	EACSessionExpired(session:Session);
}
#end

@:autoBuild(sapo.route.AccessControl.resolveMetas())
class AccessControl {
	public static inline var META = "authorize";
	public static inline var META_ALL = "authorizeAll";
	public static inline var PRIVILEGE = "common.db.MoreTypes.Privilege";

#if macro
	public static function resolveMetas(required=true, verbs=true)
	{
		var vals = switch Context.getType(PRIVILEGE) {
			case TEnum(_.get() => t, _): t.constructs;
			case other: Context.error('Internal: error while searching for Enum type $PRIVILEGE', Context.currentPos());
		}
		var valNames = [ for (n in vals.keys()) n ];

		var prefixes = ["do"];
		if (verbs) prefixes = prefixes.concat(["get", "post"]);

		var fields = Context.getBuildFields();
		for (f in fields) {
			for (m in f.meta) {
				switch m.name.split(":") {
				case [META]:
					var params = m.params;
					m.params = [];
					if (params.length == 0)
						Context.warning('Route not authorized to anyone: ${f.name}', f.pos);
					for (p in params) {
						switch p.expr {
						case EConst(CIdent(cname)), EConst(CString(cname)):
							if (!vals.exists(cname))
								Context.fatalError('No privilege $cname (try ${valNames.join(" or ")})', m.pos);
							m.params.push(Context.makeExpr(vals.get(cname).index, m.pos));
						case _:
							Context.fatalError('Unsupported @$META value: ${p.toString()}\n' +
									'Use a $PRIVILEGE constructor: ${valNames.join(", ")}', m.pos);
						}
					}
				case [META_ALL] if (m.params.length > 0):
					Context.fatalError('Meta @$META_ALL expects no parameters', m.pos);
				case [_, META] | [_, META_ALL]:
					Context.fatalError('Access control cannot be a compiler metadata\n' +
							'Instead of @${m.name} use @$META or @$META_ALL', m.pos);
				case _:  // NOOP
				}
			}
			if (required &&
					Lambda.exists(prefixes, function (i) return StringTools.startsWith(f.name, i)) &&
					!Lambda.exists(f.meta, function (i) return i.name == META || i.name == META_ALL))
				Context.fatalError('Missing access control meta (@$META or @$META_ALL) on route ${f.name}', f.pos);

		}
		return fields;
	}
#else  // !macro
	public static function onDispatchMeta(v:String, params:Null<Array<Dynamic>>)
	{
		switch v {
		case "authorize":
			// no need to check for params.length == 0, since that has been enforced in macro mode
			var ctx = Context.loop;
			if (ctx.session == null) throw EACNotAuthorized();
			if (ctx.session.expired()) {
				ctx.session.expire();
				throw EACSessionExpired(ctx.session);
			}
			if (!Lambda.exists(params, function (i) return i == ctx.privilege.getIndex()))
				throw EACNotAuthorized(ctx.user);
		case _:  // NOOP
		}
	}
#end
}

