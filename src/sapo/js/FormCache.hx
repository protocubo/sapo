package sapo.js;

import haxe.Json;
import js.Browser;
import js.jquery.*;
import js.Lib;

class FormCache {
	static function main()
	{
		new JQuery().ready(function() {
			
			var search = Browser.location.search;
			search = search.substr(1);
			var params = search.split("&");
			for (p in params)
			{
				var v = p.split("=");
				var elem = new JQuery('input[name=\'' + v[0] + '\']');
				if (elem == null || elem.length == 0)
					elem = new JQuery('select[name=\'' + v[0] + '\']');
				elem.val(v[1]);
			}
			
		});

	}
}

