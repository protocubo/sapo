package sapo.route;

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;

class AccessControlBuild {
	static inline var PRIVILEGE = "common.db.MoreTypes.Privilege";
	public static inline var META = "authorize";
	public static inline var META_ALL = "authorizeAll";

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
}

#if !macro
@:autoBuild(sapo.route.AccessControlBuild.resolveMetas())
interface AccessControl {}
#end

