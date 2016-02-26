package common.spod;
import common.spod.Familia;
import common.spod.Modo;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import haxe.io.Eof;
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

		if (!TableCreate.exists(Modo.manager)) {
			Manager.cnx.request("BEGIN");
			try {
				TableCreate.create(Familia.manager);
				TableCreate.create(Modo.manager);
				TableCreate.create(Morador.manager);
				TableCreate.create(Ponto.manager);
				TableCreate.create(Survey.manager);
				TableCreate.create(Ocorrencias.manager);

				/******/
				TableCreate.create(Referencias.manager);
				TableCreate.create(UF.manager);
				TableCreate.create(LinhaOnibus.manager);
				TableCreate.create(EstacaoMetro.manager);
				populateStatics();
				//Porrada de Enums
				var classes = CompileTime.getAllClasses("common.spod", true, EnumTable);
				for (c in classes)
					TableCreate.create(Reflect.field(c, "manager"));
				populateEnumTable();
				//TODO:Populate statics

			} catch (e:Dynamic) {
				Manager.cnx.request("ROLLBACK");
				neko.Lib.rethrow(e);
			}
			Manager.cnx.request("COMMIT");
		}
	}

	static function populateEnumTable()
	{
		var classes = CompileTime.getAllClasses("common.spod", true, EnumTable);
		trace(classes.length);
		if (classes.length == 0)
		{
			throw "No classes found!";
		}
		
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
	
	static function populateStatics()
	{
		var path = "./private/csvs/";
		if (!FileSystem.exists(path))
		{
			trace("No CSVs detected @./private/csvs/");
			return;
		}
		
		//Manager.cnx.startTransaction();
		var files = FileSystem.readDirectory(path);
		for (f in files)
		{
			if (StringTools.endsWith(f,".csv"))
			{
				var file = File.read(path + f, false);
				try
				{
					var fields = file.readLine().split(";");
					while (true)
					{
						var params = file.readLine().split(";");
						var cl = Type.resolveClass("common.spod.statics." + f.split(".")[0]);
						var instance = Type.createEmptyInstance(cl);
						var i = 0;
						while (i < fields.length)
						{
							Reflect.setField(instance, fields[i], params[i]);
							i++;
						}
						instance.insert();
					}
				}
				catch (e : Eof)
				{
					trace("File " + f +" added!");
					Manager.cnx.commit();
				}
			}
		}
		
		
	}
}
