package js;

/**
 * ...
 * @author Caio
 */
@:expose class Localstorage
{

	public function new() 
	{
		
	}
	
	public static function run()
	{
		new JQuery("document").ready(function()
		{
			if (Browser.getLocalStorage() == null)
				return;
			
			var localstorage = Browser.getLocalStorage();
			var i = 0;
			while (i < localstorage.length)
			{
				var key = localstorage.key(i);
				new JQuery("select[name='" + key + "']").val(localstorage.getItem(key));
				localstorage.removeItem(key);
			}
			
			
		});
	}
	
	public static function onSubmit()
	{
		if(Browser.getLocalStorage() == null)
			return;
		var localstorage = Browser.getLocalStorage();
		new JQuery("select").each(function(i, elem)
		{
			var cur = new JQuery(elem);
			localstorage.setItem(cur.attr("name"), cur.val());
		});
	}
	
}