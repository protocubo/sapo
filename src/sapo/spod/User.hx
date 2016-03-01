package sapo.spod;

import common.crypto.Password;
import common.db.MoreTypes;
import sys.db.Object;
import sys.db.Types;

@:index(group_name, unique)
class Group extends sys.db.Object {
	public var id:SId;
	public var privilege:SEnum<Privilege>;
	public var group_name:AccessName;
	public var name:String;

	public function new(privilege, group_name, name)
	{
		this.privilege = privilege;
		this.group_name = group_name;
		this.name = name;
		super();
	}
}

@:index(email, unique)
class User extends sys.db.Object {
	public var id:SId;
	@:relation(group_id) public var group:Group;
	public var email:EmailAddress;
	public var name:String;
	@:relation(supervisor_id) public var supervisor:Null<User>;

	public var password:Null<Password>;

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
class Session extends sys.db.Object {
	public static inline var COOKIE_KEY = "session_id";
	public static inline var DEFAULT_SESSION_DURATION = 24*3.6*1e6;  // unit: ms

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

