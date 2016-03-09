/*
 * Improved Web apis.
 *
 * Fixes and extends neko.Web.
 *
 * Based on and licensed as the original neko.Web.
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package common;

import neko.Web in W;

@:forwardStatics
@:access(neko.Web)
abstract Web(W) from W {
#if neko
	static var date_get_tz = neko.Lib.load("std","date_get_tz", 0);
	static function getTimezoneDelta():Float return 1e3*date_get_tz();
#end
	/**
		Returns all GET and POST parameters.
	**/
	public static function getAllParams()
	{
		var p = W._get_params();
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
		var p = W._get_cookies();
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
		Set a Cookie value in the HTTP headers. Same remark as setHeader.

		Fixed in regards to hosts running on timezones differents than GMT.
	**/
	public static function setCookie( key : String, value : String, ?expire: Date, ?domain: String, ?path: String, ?secure: Bool, ?httpOnly: Bool ) {
		var buf = new StringBuf();
		buf.add(value);
		expire = DateTools.delta(expire, -getTimezoneDelta());
		if( expire != null ) W.addPair(buf, "expires=", DateTools.format(expire, "%a, %d-%b-%Y %H:%M:%S GMT"));
		W.addPair(buf, "domain=", domain);
		W.addPair(buf, "path=", path);
		if( secure ) W.addPair(buf, "secure", "");
		if( httpOnly ) W.addPair(buf, "HttpOnly", "");
		var v = buf.toString();
		W._set_cookie(untyped key.__s, untyped v.__s);
	}

	public static function getLocalReferer():Null<String>
	{
		var r = W.getClientHeader("Referer");
		if (r == null) return null;
		if (r.indexOf("#") >= 0) r = r.substr(0, r.indexOf("#"));  // shouldn't fragments anyways
		var h = W.getClientHeader("Host");
		var p = r.indexOf(h);
		if (p == -1) {
			if (r == "about:blank") return null;
			return r;
		}
		return r.substr(p + h.length);
	}
}

