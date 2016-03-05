package sapo.spod;

import common.crypto.Password;
import common.crypto.Random;
import common.db.MoreTypes;
import sys.db.Manager;
import sys.db.Object;
import sys.db.Types;

class Group extends Object {
	public var id:SId;
	public var privilege:SEnum<Privilege>;
	public var name:String;

	public function new(privilege, name)
	{
		this.privilege = privilege;
		this.name = name;
		super();
	}
}

@:index(email, unique)
class User extends Object {
	public var id:SId;
	@:relation(group_id) public var group:Group;
	public var email:EmailAddress;
	public var name:String;
	@:relation(supervisor_id) public var supervisor:Null<User>;

	public var password:Null<Password>;
	public var deactivated_at:Null<HaxeTimestamp>;

	public function new(group, email, name, ?supervisor)
	{
		this.group = group;
		this.email = email;
		this.name = name;
		this.supervisor = supervisor;
		if (group.privilege.match(PSurveyor) && supervisor == null)
			throw 'Can\'t create surveyor $email: lacking supervisor';

		super();
	}
}

@:id(id)
class Session extends Object {
	public static inline var COOKIE_KEY = "session_id";
	public static inline var DEFAULT_SESSION_DURATION = 24*3.6*1e6;  // unit: ms

	public var id:String;
	@:relation(user_id) public var user:User;
	public var created_at:HaxeTimestamp;
	public var expires_at:HaxeTimestamp;
	public var expired_at:Null<HaxeTimestamp>;

	public function expired(?at:HaxeTimestamp)
	{
		if (at == null) at = Context.now;
		return expired_at != null || (expires_at < at);
	}

	public function expire(?autoUpdate=true)
	{
		if (expired_at != null) return;
		expired_at = expires_at < Context.now ? expires_at : Context.now;
		if (autoUpdate)
			update();
	}

	public function new(user, ?duration=DEFAULT_SESSION_DURATION)
	{
		this.user = user;
		id = common.crypto.Random.global.readSimpleBytes(16).toHex();
		created_at = Context.now;
		expires_at = created_at + duration;
		super();
	}
}

@:id(token)
class Token extends Object {
	public var token : SString<255>;
	@:relation(user_id) public var user : User;
	public var expirationTime(default,null) : HaxeTimestamp;
	public var isExpired(default,null) : SBool = false;
	
	public function new(user)
	{
		super();
		this.user = user;
		
		//Porco..corrigir depois
		this.token = Random.global.readHex(64);
		this.expirationTime = DateTools.delta(Context.now.toDate(), 1000.0 * 60 * 60 * 24 * 7).getTime();
		
	}
	
	public function setExpired()
	{
		this.isExpired = true;
	}
	
	public function invalidateOthers()
	{
		if (this.user == null)
			return;
		Manager.cnx.startTransaction();
		
		var tokens = Token.manager.search($user == this.user, null, true);
		for (t in tokens)
		{
			if (t != this)
			{
				t.isExpired = true;
				t.update();
			}
		}
		
		Manager.cnx.commit();
	}
}

