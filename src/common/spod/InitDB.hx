package common.spod;
import common.spod.Familia;
import common.spod.Modo;
import haxe.Json;
import haxe.rtti.Meta;
import common.spod.statics.Referencias;
import common.spod.EnumSPOD;
import common.spod.statics.UF;
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
	static var DBPATH = Sys.getEnv("SAPO_DB");

	public static function run()
	{
		Manager.initialize();

		Manager.cnx = Sqlite.open(DBPATH);
		Manager.cnx.request("PRAGMA page_size = 4096");
		// later windows can't close the connection in wal mode...
		// an issue with sqlite.ndll perhaps?
		if (Sys.systemName() != "Windows") Manager.cnx.request("PRAGMA journal_mode=wal");

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
			var classes = CompileTime.getAllClasses("common.spod", true, EnumTable);
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
		var classes = CompileTime.getAllClasses("common.db", true, EnumTable);
		trace(classes.length);
		for (c in classes)
		{
			trace(Type.getClassName(c));
			var classEnum = Type.resolveEnum(Type.getClassName(c).split("_")[0]);
			trace(Type.getEnumName(classEnum));
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
				Reflect.setField(instance, "val", val);
				instance.insert();
			}
		}


	}
}
