package sapo;

import common.Web;
import haxe.PosInfos;

class Index {
	static function main()
	{
		haxe.Log.trace = function (msg, ?pos:haxe.PosInfos) {
			if (pos.customParams != null) msg += "\n{" + pos.customParams.join(" ") + "}";
			msg += '  @${pos.className}:${pos.methodName}  (${pos.fileName}:${pos.lineNumber})';
			Web.logMessage(msg);
		}

#if trace_sqlite
		{
			var underlying = untyped sys.db._Sqlite.SqliteConnection._request;
			untyped sys.db._Sqlite.SqliteConnection._request = function (c:Dynamic, sql:Dynamic) {
				trace('SQLite: ${new String(sql)}');
				return underlying(c, sql);
			}
		}
#end

		try {
			if (Web.getURI() == "/reset") {
				trace("WARNING route handled manually; /reset");
				Populate.reset();
				Web.redirect("/login");
				return;
			}

			Context.init();  // db init (reserved for future cache operation on tora)
			Context.iterate();  // dispatch happens here
			Context.shutdown();
		} catch (e:Dynamic) {
			Context.shutdown();
			neko.Lib.rethrow(e);
		}
	}
}

