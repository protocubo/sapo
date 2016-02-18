package sync;
import haxe.macro.Expr;
class Macros {
	public static macro function getStaticEnum(target : Expr, old_value : Expr)
	{
		return macro $target.createByIndex(refValue.get(Type.getEnumName($target)).get($old_value));
	}
	
	public static macro function checkEnumValue(target : Expr, name : Expr, old_value : Expr)
	{
		return macro {
			if ($target.get($name) == null)
			{
				trace("Table $name doesn't exist!");
				//TODO: Warn something;
			}
			else if($target.get($name).get($old_value) == null)
			{
				trace("Enum $old_value value doesnt exist!");
				//TODO: Warn something;
			}
		};
	}
}
