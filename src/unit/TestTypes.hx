package unit;

import sys.db.*;

class FlagObject extends Object {
	public var id:Types.SId;
	public var flag:Bool;

	public function new(b:Bool)
	{
		this.flag = b;
		super();
	}
}

class CnxManager<T:Object> extends Manager<T> {
	var cnx:Connection;

	override function getCnx()
		return cnx;

	public function new(cl, cnx)
	{
		this.cnx = cnx;
		super(cl);
	}
}

