package common.crypto;

import Std.parseInt;
import haxe.crypto.*;
import haxe.io.Bytes;
#if hxBitcoin
import com.fundoware.engine.crypto.hash.FunSHA2_256 in FwSha256;
import com.fundoware.engine.crypto.hmac.FunHMAC_SHA256 in FwHmac;
import com.fundoware.engine.crypto.pbe.FunPBKDF2_HMAC_SHA256 in FwPbkdf2;
import com.fundoware.engine.crypto.scrypt.FunScrypt in FwScrypt;
#end

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
#if hxBitcoin
	// Scrypt tuned for intereactive logins
	//  - hash will always be HMAC-SHA256
	//  - n: general work factor
	//  - r: blocksize in use for underlying hash
	//  - p: parallezition factor
	PSScrypt(salt:Bytes, n:Int, r:Int, p:Int, dkLen:Int);
#end
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

#if hxBitcoin
	static function scrypt(plain:Bytes, salt:Bytes, n:Int, r:Int, p:Int, dkLen:Int):String
	{
		var impl = new FwScrypt(n, r, p, new FwPbkdf2(new FwHmac(new FwSha256())));
		return impl.run(plain, salt, 1, dkLen).toHex();
	}
#end

	static function pwdString(plain:Bytes, store:PasswordStore)
	{
		return switch store {
		case PSSaltedSha1(salt, it):
			'sha1$$$it$$${salt.toHex()}$$${saltedSha(Sha1.make, plain, salt, it)}';
		case PSSaltedSha256(salt, it):
			'sha256$$$it$$${salt.toHex()}$$${saltedSha(Sha256.make, plain, salt, it)}';
		case PSPlain:
			'plain$$${plain.toString()}';
#if hxBitcoin
		case PSScrypt(salt, n, r, p, dkLen):
			'scrypt$$$n$$$r$$$p$$$dkLen$$${salt.toHex()}$$${scrypt(plain, salt, n, r, p, dkLen)}';
#end
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
#if hxBitcoin
		case ["scrypt", n, r, p, dkLen, salt, hash]:
			slowStringEquals(hash, scrypt(pbytes, decodeHex(salt), parseInt(n), parseInt(r), parseInt(p), parseInt(dkLen)));
#end
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
#if hxBitcoin
			store = PSScrypt(salt, 256, 8, 1, 64);
#else
			store = PSSaltedSha256(salt, 42);
#end
		}
		return new Password(pwdString(Bytes.ofString(plain), store));
	}
}

