package common.tools;

class CallStackTools {
	// based on std.haxe.CallStack.itemToString
	public static function toString(i:haxe.CallStack.StackItem)
	{
		return switch i {
		case CFunction: "[C code]";
		case Module(m): '[module $m]';
		case FilePos(s,file,line):
			file = haxe.io.Path.normalize(file);
			var sl = file.lastIndexOf("/");
			if (sl >= 0)
				file = file.substr(sl + 1);
			if (s != null)
				'${toString(s) + "@"}$file:$line';
			else
				'$file:$line';
		case Method(cname,meth): '$cname.$meth';
		case LocalFunction(n): '[local func]';
		}
	}
}

