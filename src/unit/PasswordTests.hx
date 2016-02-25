package unit;

import common.crypto.Password;
import haxe.io.Bytes;
import utest.Assert;

@:keep
class PasswordTests {
	var plain = ["asdfgh123456", "hello", "foo", ""];

	function bytes(s:String) return Bytes.ofString(s);

	public function test_000_testDefaultSecurity()
	{
		var pwds = plain.map(function (p) return Password.make(p));
		var salts = new Map();
		for (pwd in pwds.map(function (p:String) return p.split("$"))) {
#if hxBitcoin
			Assert.equals("scrypt", pwd[0]);
			Assert.equals("256", pwd[1]);
			Assert.equals("8", pwd[2]);
			Assert.equals("1", pwd[3]);
			Assert.equals("64", pwd[4]);
			Assert.equals(10, pwd[5].length);
			Assert.isFalse(salts.exists(pwd[5]));
			salts[pwd[5]] = true;
#else
			Assert.equals("sha256", pwd[0]);
			Assert.equals("42", pwd[1]);
			Assert.equals(10, pwd[2].length);
			Assert.isFalse(salts.exists(pwd[2]));
			salts[pwd[2]] = true;
#end
		}
	}

	public function test_001_testPlain()
	{
		for (p in plain) {
			var pwd = Password.make(p, PSPlain);
			Assert.equals('plain$$$p', pwd);
			Assert.isTrue(pwd.matches(p));
		}
	}

	public function test_002_testSha1()
	{
		Assert.equals("sha1$1$776f726c64$6adfb183a4a2c94a2f92dab5ade762a47889a5a1",
			Password.make("hello", PSSaltedSha1(bytes("world"), 1)));
		for (p in plain) {
			var pwd = Password.make(p, PSSaltedSha1(bytes("saaalt"), 2));
			Assert.isTrue(StringTools.startsWith(pwd, "sha1$2$736161616c74$"));
			Assert.isTrue(pwd.matches(p));
			var hash = (pwd:String).split("$").pop();
			Assert.equals(40, hash.length);
		}
	}

	public function test_003_testSha256()
	{
		Assert.equals("sha256$1$776f726c64$936a185caaa266bb9cbe981e9e05cb78cd732b0b3280eb944412bb6f8f8f07af",
			Password.make("hello", PSSaltedSha256(bytes("world"), 1)));
		for (p in plain) {
			var pwd = Password.make(p, PSSaltedSha256(bytes("saaalt"), 2));
			Assert.isTrue(StringTools.startsWith(pwd, "sha256$2$736161616c74$"));
			Assert.isTrue(pwd.matches(p));
			var hash = (pwd:String).split("$").pop();
			Assert.equals(64, hash.length);
		}
	}

#if hxBitcoin
	@:access(common.crypto.Password.scrypt)
	public function test_004_testScrypt()
	{
		Assert.equals(
			"77d6576238657b203b19ca42c18a0497f16b4844e3074ae8dfdffa3fede21442fcd0069ded0948f8326a753a0fc81f17e8d3e0fb2e0d3628cf35e20c38d18906",
			Password.scrypt(bytes(""), bytes(""), 16, 1, 1, 64));
		// Assert.equals(
		// 	"fdbabe1c9d3472007856e7190d01e9fe7c6ad7cbc8237830e77376634b3731622eaf30d92e22a3886ff109279d9830dac727afb94a83ee6d8360cbdfa2cc0640",
		// 	Password.scrypt(bytes("password"), bytes("NaCl"), 1024, 8, 16, 64));
		// Assert.equals(
		// 	"7023bdcb3afd7348461c06cd81fd38ebfda8fbba904f8e3ea9b543f6545da1f2d5432955613f0fcf62d49705242a9af9e61e85dc0d651e40dfcf017b45575887",
		// 	Password.scrypt(bytes("pleaseletmein"), bytes("SodiumChloride"), 16384, 8, 1, 64));
		// Assert.equals(
		// 	"2101cb9b6a511aaeaddbbe09cf70f881ec568d574a2ffd4dabe5ee9820adaa478e56fd8f4ba5d09ffa1c6d927c40f4c337304049e8a952fbcbf45c6fa77a41a4",
		// 	Password.scrypt(bytes("pleaseletmein"), bytes("SodiumChloride"), 1048576, 8, 1, 64));
		for (p in plain) {
			var pwd = Password.make(p, PSScrypt(bytes("saaalt"), 2, 8, 1, 32));
			Assert.isTrue(StringTools.startsWith(pwd, "scrypt$2$8$1$32$736161616c74$"));
			Assert.isTrue(pwd.matches(p));
			var hash = (pwd:String).split("$").pop();
			Assert.equals(64, hash.length);
		}
	}
#end

	public function new() {}
}

