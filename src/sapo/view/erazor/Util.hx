package sapo.view.erazor;

@:includeTemplate("util/head.html")
class Head extends erazor.macro.HtmlTemplate {
	var title:String;

	public function new(title)
	{
		this.title = title;
		super();
	}
}

