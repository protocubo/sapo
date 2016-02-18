package common.crypto;

import haxe.io.*;

class StdRandomInput extends Input {
	override public inline function readByte()
		return Std.random(256);

	public function new() {}
}

class Random extends Input {
	var gen:Input;

	function new(gen:Input)
		this.gen = gen;

	public static var global(default,null):Input;

	override public inline function readByte()
		return gen.readByte();

	public function readHex(len:Int):String
	{
		var b = Bytes.alloc(len);
		var got = 0;
		while (got < len)
			got += readBytes(b, got, len - got);
		return b.toHex();
	}

	static function __init__()
	{
		var gen = switch Sys.systemName() {
		case "Windows":
			trace("WARNING no real random generator used on Windows");
			new StdRandomInput();
		case _:
			sys.io.File.read("/dev/urandom", true);
		}
		global = new Random(gen);
	}
}

