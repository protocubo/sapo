package common;

@:forwardStatics
@:access(neko.Web)
abstract Web(neko.Web) from neko.Web {
	/**
		Returns all GET and POST parameters.
	**/
	public static function getAllParams()
	{
		var p = neko.Web._get_params();
		var h = new Map<String, Array<String>>();
		var k = "";
		while( p != null ) {
			untyped k.__s = p[0];
			if (!h.exists(k)) h.set(k, []);
			h.get(k).push(new String(p[1]));
			p = untyped p[2];
		}
		return h;
	}

	/**
		Returns all Cookies sent by the client, including multiple values for any given key.

		Modifying the hashtable will not modify the cookie, use setCookie or addCookie instead.
	**/
	public static function getAllCookies() {
		var p = neko.Web._get_cookies();
		var h = new Map<String, Array<String>>();
		var k = "";
		while( p != null ) {
			untyped k.__s = p[0];
			if (!h.exists(k)) h.set(k, []);
			h.get(k).push(new String(p[1]));
			p = untyped p[2];
		}
		return h;
	}
}
