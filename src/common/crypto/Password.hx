package common.crypto;

import haxe.io.Bytes;
import haxe.crypto.*;

// use the best you can
enum PasswordStorage {
	// for testing purposes only
	PSPlain;
	// Dumb (iterated) salted SHA1:
	// out[i] = sha1(out[i-1]) where out[0] = pwd + salt
	PSSaltedSha1(salt:Bytes, iterations:Int);
	// Dumb (iterated) salted SHA2-256:
	// out[i] = sha256(out[i-1]) where out[0] = pwd + salt
	PSSaltedSha256(salt:Bytes, iterations:Int);
#if hxBitcoin
	// Scrypt tuned for intereactive logins
	//  - hash will always be HMAC-SHA256
	//  - N: general work factor
	//  - r: blocksize in use for underlying hash
	//  - p: parallezition factor
	PSScrypt(salt:Bytes, N:Int, r:Int, p:Int, dkLen:Int);
#end
}

abstract Password(String) to String {
	static function concatBytes(a:Bytes, b:Bytes)
	{
		var res = Bytes.alloc(a.length + b.length);
		res.blit(0, a, 0, a.length);
		res.blit(a.length, b, 0, b.length);
		return res;
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

	static function saltedSha(sha:Bytes->Bytes, plain:Bytes, salt:Bytes, it:Int):String
	{
		var hash = null;
		do {
			hash = sha(concatBytes(hash, salt));
		} while (--it > 0);
		return hash.toHex();
	}

	public function matches(plain:String)
	{
		if (this == null) return false;

		var pbytes = Bytes.ofString(plain);
		return switch this.split("$") {
		case ["sha1", it, salt, hash]:
			slowStringEquals(hash, saltedSha(Sha1.make, pbytes, Bytes.ofString(salt), Std.parseInt(it)));
		case ["sha256", it, salt, hash]:
			slowStringEquals(hash, saltedSha(Sha256.make, pbytes, Bytes.ofString(salt), Std.parseInt(it)));
		case ["plain", p]:
			slowStringEquals(p, plain);
		case _:
			trace('unsupported pwd string "${this.substr(0, 4)}..."');
			false;
		}
	}

	public function new(pwd)
		this = pwd;

	public static function make(plain:String)
	{
		// viable (not sensible) defaults
		var salt = Bytes.alloc(16);
		var saltLen = 0;
		while (saltLen < 16)
			saltLen += Random.global.readBytes(salt, 0, 16 - saltLen);
		var store = PSSaltedSha256(salt, 42);
		return new Password(makeRaw(Bytes.ofString(plain), store));
	}

	public static function makeRaw(plain:Bytes, store:PasswordStorage)
	{
		return switch store {
		case PSSaltedSha1(salt, it):
			'sha1$$$it$$${salt.toHex()}$$${saltedSha(Sha1.make, plain, salt, it)}';
		case PSSaltedSha256(salt, it):
			'sha256$$$it$$${salt.toHex()}$$${saltedSha(Sha256.make, plain, salt, it)}';
		case PSPlain:
			'plain$$${plain.toHex()}';
		}
	}
}

