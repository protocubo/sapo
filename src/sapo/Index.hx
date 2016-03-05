package sapo;

import common.Web;
import haxe.PosInfos;
import sys.io.File;

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
			var sclass = untyped sys.db._Sqlite;
			var uclass = sclass.SqliteConnection;
			var ufuncs = {
				_request : uclass._request,
				_connect : uclass._connect,
				_close : uclass._close
			}
			uclass._request = function (c:Dynamic, sql:Dynamic) {
				trace('SQLite.sql: ${new String(sql)}');
				return ufuncs._request(c, sql);
			}
			uclass._connect = function (file:Dynamic) {
				trace('SQLite.open: $file');
				return ufuncs._connect(file);
			}
			uclass._close = function (c:Dynamic) {
				trace('SQLite.close');
				ufuncs._close(c);
			}
		}
#end

		try {
			if (Web.getURI() == "/reset") {
				trace("WARNING route handled manually; /reset");
				Context.resetMainDb();
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

