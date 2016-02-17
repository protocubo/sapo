package common.crypto;

import haxe.io.Bytes;
import haxe.crypto.*;

enum PasswordStorage {
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
#if debug
	// for testing purposes only
	PSPlain;
#end
}

abstract Password(String) to String {
	function makeHash(plain:Bytes, store:PasswordStorage)
	{
		switch store {
		case PSSaltedSha1(salt, iterations):
			// 'sha1$$$iterations$$${Sha1.
		case PSSaltedSha256(salt, iterations):
#if hxBitcoin
		case PSScrypt(salt, N, r, p, dkLen):
#end
#if debug
		case PSPlain:
#end
		}
		return "";
	}

	public function new(plain, store)
	{
		this = "";
		this = makeHash(Bytes.ofString(plain), store);
	}
}

