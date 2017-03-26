package sapo;

import common.Web;
import haxe.PosInfos;
import sys.io.File;

class Index {
	static var timers:Map<String,{ count:Int, time:Float }>;

	static function printTimers()
	{
		var values = [ for (k in timers.keys()) { key:k, val:timers[k] } ];
		values.sort(function (a,b) return Reflect.compare(b.val.time, a.val.time));
		var buf = new StringBuf();
		buf.add("timers:\n");
		for (val in values) {
			var k = val.key;
			var v = val.val;
			var tcall = v.count > 0 ? v.time/v.count : 0.;
			var totalScale = instrument.TimeCalls.autoScale(v.time);
			var callScale = instrument.TimeCalls.autoScale(tcall);
			buf.add('  ${k}: ${v.count} calls, ${Math.round(tcall*callScale.divisor)}${callScale.symbol}/call, ${Math.round(v.time*totalScale.divisor)}${totalScale.symbol} in total\n');
		}
		return buf.toString();
	}

	static function main()
	{
		haxe.Log.trace = function (msg, ?pos:haxe.PosInfos) {
			if (pos.customParams != null) msg += "\n{" + pos.customParams.join(" ") + "}";
			msg += '  @${pos.className}:${pos.methodName}  (${pos.fileName}:${pos.lineNumber})\n';
			Sys.stderr().writeString(msg);
		}

		timers = new Map();
		var defaultOnTimed = instrument.TimeCalls.onTimed;
		instrument.TimeCalls.onTimed = function (start, finish, ?pos:haxe.PosInfos) {
			var key = '${pos.className}.${pos.methodName}';
			if (timers.exists(key)) {
				var t = timers[key];
				t.count++;
				t.time += finish - start;
			} else {
				timers[key] = { count:1, time:(finish - start) };
			}
		}

		try {
			if (Web.getURI() == "/reset") {
				trace("WARNING route handled manually; /reset");
				Populate.reset();
				Web.redirect("/login");
				return;
			}

			Context.init(true);  // db init (reserved for future cache operation on tora)
			Context.iterate();  // dispatch happens here
			Context.shutdown();
			trace(printTimers());
		} catch (e:Dynamic) {
			Context.shutdown();
			trace('ERROR (unknown): $e');
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			Web.redirect("/500.html");
		}
	}
}

