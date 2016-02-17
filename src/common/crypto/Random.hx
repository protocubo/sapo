package common.crypto;

class StdRandomInput extends Input {
	override public function readByte()
		return Std.random(256);
}

class Random {
	static var gen:haxe.io.Input;

	static function __init__()
	{
		gen = switch Sys.systemName() {
		case "Windows":
			trace("WARNING no real random generator used on Windows");
			new StdRandomInput();
		case "_":
			sys.io.File.read("/dev/urandom", true);
		}
	}
}

