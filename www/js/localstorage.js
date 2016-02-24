/**
 * ...
 * @author Caio
 */

$('document').ready(function()
{
	if(localStorage == null)
		return;
	
	var i = 0;
	while(i < localStorage.length)
	{
		var key = localStorage.key(i);
		$("select[name='" + key + "']").val(localStorage.getItem(key));
		localStorage.removeItem(key);
	}
	
	$("form[name='filter']").submit(onFilterSubmit);
});


function onFilterSubmit()
{
	if(localStorage == null)
		return;
	
	$("select").each(function(i,elem)
	{
		var cur = $(elem);
		localStorage.setItem(cur.attr("name"), cur.val());
	});
}