package common.crypto;

import haxe.io.*;

class StdRandomInput extends Input {
	override public inline function readByte()
		return Std.random(256);
}

class Random extends Input {
	static var gen:Input;

	override public inline function readByte()
		return gen.readByte();

	public function readHex(len:Int):String
	{
		var b = new Bytes(len);
		var got = 0;
		while (got < len)
			got += readBytes(b, got, len - got);
		return b.toHex();
	}

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

