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

	public static var global(default,null):Random;

	override public inline function readByte()
		return gen.readByte();

	public function readSimpleBytes(len:Int):Bytes
	{
		var b = Bytes.alloc(len);
		gen.readFullBytes(b, 0, len);
		return b;
	}

	public function readHex(len:Int):String
		return readSimpleBytes(len).toHex();

	static function __init__()
	{
		var gen = switch Sys.systemName() {
		case "Windows":
			Sys.stderr().writeString("WARNING no real random generator used on Windows\n");
			new StdRandomInput();
		case _:
			sys.io.File.read("/dev/urandom", true);
		}
		global = new Random(gen);
	}
}

