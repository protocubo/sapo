package sapo.js;

import js.Browser;
import js.jquery.*;

class FormCache {
	static function onSubmit(_)
	{
		var local = Browser.getLocalStorage();
		new JQuery("select").each(function(i, elem)
		{
			var cur = new JQuery(elem);
			local.setItem(cur.attr("name"), cur.val());
		});
	}

	static function main()
	{
		new JQuery().ready(function() {
			var local = Browser.getLocalStorage();
			if (local == null) {
				trace("No local storage");
				return;
			}
			var i = 0;
			while (i < local.length) {
				var key = local.key(i);
				new JQuery("select[name='" + key + "']").val(local.getItem(key));
				local.removeItem(key);
			}
			new JQuery("form[name='filter']").submit(onSubmit);
		});

	}
}

