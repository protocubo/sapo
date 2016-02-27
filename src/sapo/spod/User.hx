package sapo.spod;

import common.crypto.Password;
import common.db.MoreTypes;
import sys.db.Types;

// necessary only because we need mentions to groups
@:index(group_name, unique)
class Group extends sys.db.Object {
	public var id:SId;
	public var group_name:AccessName;
	public var privilege:SEnum<Privilege>;

	public function new(group_name, privilege)
	{
		this.group_name = group_name;
		this.privilege = privilege;
		super();
	}
}

@:index(user_name, unique)
@:index(email, unique)
class User extends sys.db.Object {
	public var id:SId;
	public var user_name:AccessName;
	@:relation(group_id) public var group:Group;
	public var name:String;
	public var email:EmailAddress;
	public var password:Null<Password>;

	public function new(user_name, group, name, email)
	{
		this.user_name = user_name;
		this.group = group;
		this.email = email;
		this.name = name;
		super();
	}
}

@:key(id)
class Session extends sys.db.Object {
	public static inline var COOKIE_KEY = "session_id";
	public static inline var DEFAULT_SESSION_DURATION = 3.6*1e6;  // ms

	public var id:String;
	@:relation(user_id) public var user:User;
	public var created_at:HaxeTimestamp;
	public var expires_at:HaxeTimestamp;
	public var expired_at:Null<HaxeTimestamp>;

	public function expired()
		return expired_at != null || (expires_at < Context.loop.now);

	public function expire(?autoUpdate=true)
	{
		if (expired_at != null) return;
		expired_at = expires_at < Context.loop.now ? expires_at : Context.loop.now;
		if (autoUpdate)
			update();
	}

	public function new(user, ?duration=DEFAULT_SESSION_DURATION)
	{
		this.user = user;
		id = common.crypto.Random.global.readSimpleBytes(16).toHex();
		created_at = Context.loop.now;
		expires_at = Context.loop.now + duration;
		super();
	}
}

