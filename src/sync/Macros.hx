package sync;
import common.stringTools.Tools;
import haxe.macro.Expr;
class Macros {
	
	public static macro function setEnumField(field : Expr, new_entry : Expr, old_entry : Expr)
	{
		return macro {
			var norm_field = $field.split("_")[0];
			//trace(Tools.capitalize(norm_field));
			var e = Type.resolveEnum("common.spod." + Tools.capitalize(norm_field));
			if (Macros.checkEnumValue(e, Reflect.field($old_entry, $field)))
				Reflect.setProperty($new_entry, norm_field, Macros.getStaticEnum(e, Reflect.field($old_entry, $field)));
		}
	}
	
	
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
			
			//trace("refValue " + refValue.get(name));
			if (refValue.get(name) == null)
			{
				Macros.warnTable(name, null, null);
				false;
			}
			else if($old_value != null && refValue.get(Type.getEnumName($target)).get($old_value) == null)
			{
				Macros.warnEnum(name, $old_value);
				false;
			}
			else
				true;
		};
	}
	
	
	public static macro function validateEntry(tableClass : Expr, ignoreParams : Expr, whereParams : Expr, curEntry : Expr)
	{
		return macro {
			
			var fulltblname = Type.getClassName($tableClass).split(".");
			var tblname = fulltblname[fulltblname.length -1];
			
			var str = " WHERE ";
			
			var i = 0;
			while(i < $whereParams.length)
			{
				if (i != 0)
					str = str + " AND ";
				str = str + $whereParams[i].key + "=" + $whereParams[i].value;
				i++;
			}
			
			var old_entry = $tableClass.manager.unsafeObject("SELECT * FROM " + tblname + str+" ORDER BY syncTimestamp DESC LIMIT 1", false);
			
			var shouldInsert = false;
			
			for (info in $tableClass.manager.dbInfos().fields)
			{
				var field = info.name;
				
				
				if ($ignoreParams.indexOf(field) == -1 && Std.string(Reflect.getProperty($curEntry, field)) != Std.string(Reflect.getProperty(old_entry, field)))
				{
					shouldInsert = true;
				}
			}
			try{
			if (shouldInsert)
				$curEntry.insert();
			else
				$curEntry = old_entry;
			}
			catch (e : Dynamic)
			{
				Macros.criticalError(tblname, e);
			}
		}
	}
	
	public static macro function criticalError(table : Expr, error : Expr)
	{
		return macro {
				trace("Critical error on table " + $table + " : " + $error);
				//TODO: THROW!
				//trace("Press enter");
				//Sys.stdin().readLine();
		}
	}
	public static macro function warnTable(table : Expr, field : Expr, val : Expr)
	{
		return macro {
			//TODO: Implementar comunicacao
			if ($val != null)
				trace("Table " + $table + " has a problem on field " + $field + " with val " + $val);
			else if($field != null)
				trace("Table " + $table + " doesn't have field " + $field);
			else
				trace("Table " + $table + " doesn't exist!");
		};
	}
	
	public static macro function warnEnum(enumName : Expr, value : Expr)
	{
		//TODO: Implementar comunicacao
		return macro {
			trace("Enum " + $enumName + " doesn't have val " + $value);
		}
	}
}
