package sync;
import haxe.macro.Expr;
class Macros {
	public static macro function getStaticEnum(target : Expr, old_value : Expr)
	{
		return macro {
			if($old_value != null)
				$target.createByIndex(refValue.get(Type.getEnumName($target)).get($old_value));
			else
				null;
		}
	}
	
	public static macro function checkEnumValue(target : Expr, old_value : Expr)
	{
		return macro {
			var name = Type.getEnumName($target);
			if (refValue.get(name) == null)
			{
				trace("Table "+ name +" doesn't exist!");
				//TODO: Warn something;
				false;
			}
			else if($old_value != null && refValue.get(Type.getEnumName($target)).get($old_value) == null)
			{
				trace("Enum for Table "+name+  " with value " +$old_value+" doesnt exist!");
				//TODO: Warn something;
				false;
			}
			else
				true;
		};
	}
}
