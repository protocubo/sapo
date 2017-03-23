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
			trace('ERROR (unknown): $e');
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			Web.redirect("/500.html");
		}
	}
}

