package;

import haxe.crypto.BaseCode;
import haxe.crypto.Hmac;
import haxe.crypto.Hmac.HashMethod;
import haxe.Http;
import haxe.io.Bytes;
import neko.Lib;

/**
 * ...
 * @author RV
 */
class Main 
{
	static var email:String = "arthur@sapo";
	static var plain:String = "perfect";
	static var device:String = "33";
	static var token :Bytes;
	
	static function main() 
	{
		sendChallengeRequest(email);
	}
	
	public static function sendChallengeRequest(email:String)
	{
		trace("Requested sapo-Challenge");
		var req = new Http("http://localhost:2000/challenge");
		req.setHeader("Content-Type","application/x-www-form-urlencoded");
		req.setParameter( "email", email );	
		req.onData = handleResponse;
		req.request(true);
		
		
	}
	
	static function handleResponse(r:String)
	{
		trace("Token received: " + r);
		var p = r.split("$");
		var nounce = Bytes.ofString(p[4]);
		token = generateToken(Bytes.ofString(r), nounce);
		trace("TOKEN-"+token);
	}
	
	public static function registerDevice()
	{		
		/*var p = token.split("$");
		
		//Get SHA
		var sha;
		if (p[0] == "sha1")
			sha = Sha1.make;
		else if (p[0] == "sha256")
			sha = Sha256.make;
		//get iterations
		var it = Std.parseInt(p[1]);
		//get prefix
		var prefix = Std.parseInt(p[2]);
		//salt
		var salt = decode(prefix);
		//tokenID
		var id = Std.parseInt(p[3]);*/
		
		
		
	}
	
	//same function
	static function generateToken(head:Bytes, nounce:Bytes)
	{
		var hm = HashMethod.SHA256;
		var hmac = new Hmac(hm);		
		var token = hmac.make(head, nounce);
		
		return token;
	}
	
	static function decode(str:String) {
        var base = Bytes.ofString("0123456789abcdef");
        return new BaseCode(base).decodeBytes(Bytes.ofString(str.toLowerCase()));
    }
	
	static function concatBytes(a:Bytes, b:Bytes)
	{
		var res = Bytes.alloc(a.length + b.length);
		res.blit(0, a, 0, a.length);
		res.blit(a.length, b, 0, b.length);
		return res;
	}
	
}