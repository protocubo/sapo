package unit;

import common.crypto.Password;
import haxe.io.Bytes;
import utest.Assert;

class PasswordTests {
	var plain = ["asdfgh123456", "hello", "foo", ""];
	public function new() {}

	public function test_000_testDefaultSecurity()
	{
		var pwds = plain.map(function (p) return Password.make(p));
		var salts = new Map();
		for (pwd in pwds.map(function (p:String) return p.split("$"))) {
			Assert.equals("sha256", pwd[0]);
			Assert.equals("42", pwd[1]);
			Assert.equals(10, pwd[2].length);
			Assert.isFalse(salts.exists(pwd[2]));
			salts[pwd[2]] = true;
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
			Password.make("hello", PSSaltedSha1(Bytes.ofString("world"), 1)));
		for (p in plain) {
			var pwd = Password.make(p, PSSaltedSha1(Bytes.ofString("saaalt"), 2));
			Assert.isTrue(StringTools.startsWith(pwd, "sha1$2$736161616c74$"));
			Assert.isTrue(pwd.matches(p));
			var hash = (pwd:String).split("$").pop();
			Assert.equals(40, hash.length);
		}
	}

	public function test_003_testSha256()
	{
		Assert.equals("sha256$1$776f726c64$936a185caaa266bb9cbe981e9e05cb78cd732b0b3280eb944412bb6f8f8f07af",
			Password.make("hello", PSSaltedSha256(Bytes.ofString("world"), 1)));
		for (p in plain) {
			var pwd = Password.make(p, PSSaltedSha256(Bytes.ofString("saaalt"), 2));
			Assert.isTrue(StringTools.startsWith(pwd, "sha256$2$736161616c74$"));
			Assert.isTrue(pwd.matches(p));
			var hash = (pwd:String).split("$").pop();
			Assert.equals(64, hash.length);
		}
	}
}

