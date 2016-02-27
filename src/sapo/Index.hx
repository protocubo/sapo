package sapo;

import haxe.PosInfos;
import common.Dispatch;
import common.Web;
import sapo.Spod;
import sys.db.*;

class Index {
	static function main()
	{
		haxe.Log.trace = function (msg, ?pos:haxe.PosInfos) {
			if (pos.customParams != null) msg += "\n{" + pos.customParams.join(" ") + "}";
			msg += '  @${pos.className}:${pos.methodName}  (${pos.fileName}:${pos.lineNumber})';
			Web.logMessage(msg);
		}

		try {
			Context.init();  // for future optimized operation on tora
			Context.iterate();

                        var method = Web.getMethod();
			var uri = Web.getURI();
			if (uri == "/favicon.ico") return;

			if (uri == "/reset") {
				trace("WARNING route handled manually; /reset");
				Context.resetMainDb();
				Web.redirect("/");
				return;
			}

			if (uri != "/login" && (Context.loop.session == null || Context.loop.session.expired())) {
				trace('WARNING route handled manually: $uri ... redirecting to /login');
				trace(Context.loop.session);
				if (Context.loop.session != null) trace(Context.loop.session.expires_at.toDate());
				if (Context.loop.session != null) trace(Context.loop.session.expired());
				if (Context.loop.session != null && Context.loop.session.expired_at != null) trace(Context.loop.session.expired_at.toDate());
				Web.redirect("/login");
				return;
			}

			// log if we're loosing any params
			var params = Web.getParams();
			var aparams = Web.getAllParams();
			for (p in aparams.keys())
				if (aparams[p].length > 1)
					trace('WARNING multiple (${aparams[p].length}) values for param $p');

			// treat visibly empty params as missing
			var cparams = [ for (k in params.keys()) if (StringTools.trim(params.get(k)).length > 0) k => params.get(k) ];
			var d = new Dispatch(uri, cparams, method);
			d.dispatch(new Routes());

			Context.shutdown();
		} catch (e:Dynamic) {
			Context.shutdown();
			neko.Lib.rethrow(e);
		}
	}
}

