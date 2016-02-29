package sapo;

import common.Dispatch;
import common.Web;
import haxe.PosInfos;
import sapo.route.AccessControl;
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
                        var method = Web.getMethod();
			var uri = Web.getURI();
			if (uri == "/reset") {
				trace("WARNING route handled manually; /reset");
				Context.resetMainDb();
				Web.redirect("/login");
				return;
			}

			Context.init();  // for future optimized operation on tora
			Context.iterate();

			trace(Context.loop.session);
			if (Context.loop.session != null) trace(Context.loop.session.expires_at.toDate());
			if (Context.loop.session != null) trace(Context.loop.session.expired());
			if (Context.loop.session != null && Context.loop.session.expired_at != null) trace(Context.loop.session.expired_at.toDate());

			// log if we're loosing any params
			var params = Web.getParams();
			var aparams = Web.getAllParams();
			for (p in aparams.keys())
				if (aparams[p].length > 1)
					trace('WARNING multiple (${aparams[p].length}) values for param $p; we can\'t handle that yet');

			// treat visibly empty params as missing
			var cparams = [ for (k in params.keys()) if (StringTools.trim(params.get(k)).length > 0) k => params.get(k) ];
			var d = new Dispatch(uri, cparams, method);
			d.onMeta = AccessControl.onDispatchMeta;
			d.dispatch(new sapo.route.RootRoutes());

			Context.shutdown();
		} catch (e:AccessControlError) {
			Context.shutdown();
			trace('Access control error: $e');
			var url = Web.getURI();
			if (Web.getMethod().toLowerCase() == "get")
				url += "?" + [
					for (k in Web.getParams().keys())
						'${StringTools.urlEncode(k)}=${StringTools.urlEncode(Web.getParams().get(k))}'
				].join("&");
			Web.redirect('/login?redirect=${StringTools.urlEncode(url)}');
		} catch (e:Dynamic) {
			Context.shutdown();
			neko.Lib.rethrow(e);
		}
	}
}

