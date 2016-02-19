package sync.db;
import haxe.Json;
import haxe.rtti.Meta;
import sync.db.statics.Referencias;
import sync.db.statics.Statics.EnumTable;
import sync.db.statics.UF;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Sqlite;
import sys.db.TableCreate;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Caio
 */
class InitDB
{
	
	
	public static function run()
	{
		
		Manager.initialize();
		
		//TODO: Implementar cnxstring do nosso server!
		#if Debug
		if (FileSystem.exists("db.db3"))
			FileSystem.deleteFile("./db.db3")
		#end
		Manager.cnx = Sqlite.open("db.db3");
		Manager.cnx.request("PRAGMA journal_mode=WAL");
		Manager.cnx.request("PRAGMA page_size = 4096");
		
		
		if (!TableCreate.exists(Modo.manager))
		{
			TableCreate.create(Familia.manager);
			TableCreate.create(Modo.manager);
			TableCreate.create(Morador.manager);
			TableCreate.create(Ponto.manager);
			TableCreate.create(Session.manager);
			
			/******/
			TableCreate.create(Referencias.manager);
			TableCreate.create(UF.manager);
			
			//Porrada de Enums
			var classes = CompileTime.getAllClasses("sync.db.statics", true, EnumTable);
			for (c in classes)
			{
				TableCreate.create(Reflect.field(c, "manager"));
			}
			
			populateEnumTable();
			//TODO:Populate statics
		}
	}
	
	public static function populateEnumTable()
	{
		var classes = CompileTime.getAllClasses("sync.db.statics", true, EnumTable);
		trace(classes.length);
		for (c in classes)
		{
			trace(Type.getClassName(c));
			var classEnum = Type.resolveEnum(Type.getClassName(c).split("_")[0]);
			
			var nr = Meta.getType(classEnum).dbNullVal[0];
			for (field in Reflect.fields(classEnum))
			{
				trace(field);
				var instance = Type.createEmptyInstance(c);
				var obj = Reflect.field(Meta.getFields(classEnum), field);
				trace(obj);
				if (obj == null)
					continue;
				var val = obj.dbVal[0];
				 
				Reflect.setField(instance, "id", Type.enumIndex(Reflect.field(classEnum, field)));
				Reflect.setField(instance, "name", field);
				if(val != nr || nr == 0)
					Reflect.setField(instance, "val", val);
				instance.insert();
			}
		}
			
		
	}
}