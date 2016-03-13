package common.crypto;

import Std.parseInt;
import haxe.crypto.*;
import haxe.io.Bytes;

// use the best you can
enum PasswordStore {
	// for testing purposes only
	PSPlain;
	// Dumb (iterated) salted SHA1:
	// out[i] = sha1(out[i-1]) where out[0] = pwd + salt
	PSSaltedSha1(salt:Bytes, iterations:Int);
	// Dumb (iterated) salted SHA2-256:
	// out[i] = sha256(out[i-1]) where out[0] = pwd + salt
	PSSaltedSha256(salt:Bytes, iterations:Int);
}

abstract Password(String) to String {
	function new(pwd)
		this = pwd;

	static function concatBytes(a:Bytes, b:Bytes)
	{
		var res = Bytes.alloc(a.length + b.length);
		res.blit(0, a, 0, a.length);
		res.blit(a.length, b, 0, b.length);
		return res;
	}

	static function saltedSha(sha:Bytes->Bytes, plain:Bytes, salt:Bytes, it:Int):String
	{
		var hash = plain;
		do {
			hash = sha(concatBytes(hash, salt));
		} while (--it > 0);
		return hash.toHex();
	}

	static function pwdString(plain:Bytes, store:PasswordStore)
	{
		return switch store {
		case PSSaltedSha1(salt, it):
			'sha1$$$it$$${salt.toHex()}$$${saltedSha(Sha1.make, plain, salt, it)}';
		case PSSaltedSha256(salt, it):
			'sha256$$$it$$${salt.toHex()}$$${saltedSha(Sha256.make, plain, salt, it)}';
		case PSPlain:
			'plain$$${plain.toString()}';
		}
	}

	static function decodeHex(s:String)
	{
		var dec = new BaseCode(Bytes.ofString("0123456789abcdef"));
		return dec.decodeBytes(Bytes.ofString(s));
	}

	static function slowStringEquals(a:String, b:String)
	{
		var len = a.length;
		if (a.length != b.length) return false;
		var res = true;
		for (i in 0...len)
			res = res && (StringTools.fastCodeAt(a, i) == StringTools.fastCodeAt(b, i));
		return res;
	}

	public function matches(plain:String)
	{
		if (this == null) return false;

		var pbytes = Bytes.ofString(plain);
		return switch this.split("$") {
		case ["sha1", it, salt, hash]:
			slowStringEquals(hash, saltedSha(Sha1.make, pbytes, decodeHex(salt), parseInt(it)));
		case ["sha256", it, salt, hash]:
			slowStringEquals(hash, saltedSha(Sha256.make, pbytes, decodeHex(salt), parseInt(it)));
		case ["plain", p]:
			slowStringEquals(p, plain);
		case _:
			trace('unsupported pwd string "${this.substr(0, 10)}..."');
			false;
		}
	}

	public static function make(plain:String, ?store:PasswordStore)
	{
		if (store == null) {
			// viable (not sensible) defaults
			var salt = Random.global.readSimpleBytes(5);
			store = PSSaltedSha256(salt, 42);
		}
		return new Password(pwdString(Bytes.ofString(plain), store));
	}
}

