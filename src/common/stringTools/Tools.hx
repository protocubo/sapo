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
		var i = 0;
		while (i < splited.length)
		{
			var reg = ~/^\D/;
			if (reg.match(splited[i]))
			{
				splited[i] = reg.replace(splited[i], reg.matched(0).toUpperCase());
				i++;
			}
		}
		return splited.join(" ");
	}
}