package sapo;
import haxe.macro.Expr;
import haxe.rtti.Meta;
import haxe.macro.Context;
import haxe.macro.ExprTools;
/**
 * ...
 * @author Caio
 */
class MetaMacros
{
	static var privilegePath = "common.db.Privilege";
	
	public static function ReplaceMeta() : Array<Field>
	{
		var fields = Context.getBuildFields();
		for (f in fields)
		{
			var new_meta = new Metadata();
			var metas = f.meta;
			for (m in metas)
			{
				if (m.name == ":authbuild" || m.name=="authbuild")
				{
					var new_metaentry : MetadataEntry = { name : "auth", params : [], pos : m.pos };
					for (p in m.params)
					{
						var en = switch Context.getType(privilegePath)
						{
							case TEnum(_.get() => t, _): t;
							case other: throw other;
						}
						
						var vals = en.constructs;

						var index = switch p.expr {
						case EConst(CIdent(cname)), EConst(CString(cname)):
							if (!vals.exists(cname)) Context.error('__Internal__   Just kidding: no privilege $cname', m.pos);
							vals.get(cname).index;
						case other:
							Context.error('Unsupported @:authbuild value: $other', m.pos);
						}
						//var index = vals.get(ExprTools.getValue(p)).index;
						
						if(index != null)
							new_metaentry.params.push(Context.makeExpr(index, m.pos));
						else
							throw "Invalid AUTH meta name: " + p;
					}
					
					new_meta.push(new_metaentry);
				}
				else
					new_meta.push(m);
			}
			
			f.meta = new_meta;
			
			
		}
		return fields;
	}
}