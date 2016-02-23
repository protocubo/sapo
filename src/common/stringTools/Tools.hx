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
			s = reg.replace(s, reg.matched(1).toUpperCase());
		}
		
		return splited.join(" ");
	}
}