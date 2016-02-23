package common.stringTools;

/**
 * ...
 * @author Caio
 */
class Tools
{

	public function new() 
	{
		
	}
	
	public static function capitalize(target: String) : String
	{
		var splited = target.split(' ');
		for (s in splited)
		{
			var reg = ~/^\D/;
			if (reg.match(s))
			{
				trace(reg.matched(0));
				s = reg.replace(s, reg.matched(0).toUpperCase());
			}
		}
		
		return splited.join(" ");
	}
}