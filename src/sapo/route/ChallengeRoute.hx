package sapo.route;
import common.crypto.Random;
import haxe.crypto.BaseCode;
import haxe.crypto.Hmac;
import haxe.crypto.Sha1;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import sapo.spod.User;

/**
 * ...
 * @author RV
 */
class ChallengeRoute extends AccessControl 
{
	
	//testing static vars
	static var tokenID = 933;
	static var token :Bytes;
	
	@authorize(guest)
	public function doDefault(args:{ email:String} )
	{
		trace("RECIEVED REQUEST: EMAIL-" + args.email);
		var user = User.manager.select($email == args.email);
		if (user == null)
		{
			//error
		}
		trace("USER-" + user.id);
		
		//prefix
		var pwd :String = user.password;
		var p = pwd.split("$");
		var prefix = p[0] + "$" + p[1] + "$" + p[2] + "$";
		trace("PFX-" + prefix);
		
		//nounce
		var nounce = Random.global.readSimpleBytes(5);
		
		//tokenID
		var id = tokenID;
		
		//response
		var response = prefix + tokenID + "$" + nounce;		
		
		//create token
		token = generateToken(Bytes.ofString(pwd), nounce);
		trace(token);
		
		
		Sys.println(response);
	}
	
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
	
	public function new() { }
}