package unit;

import sys.db.*;
import unit.TestTypes;
import utest.Assert;

class QueryTests {
	static var db:common.db.AutocommitConnection;

	public function teardown()
	{
		if (db == null) return;
		db.close();
		db = null;
	}

	public function test_001_manager_bools()
	{
		db = Sqlite.open(":memory:");
		var m = new CnxManager(FlagObject, db);
		FlagObject.manager = m;
		Assert.raises(db.request.bind("SELECT * FROM Survey LIMIT 1"));
		TableCreate.create(FlagObject.manager);

		var f = new FlagObject(false);
		f.insert();
		var t = new FlagObject(true);
		t.insert();

		Assert.equals(1, FlagObject.manager.count($flag == false));
		Assert.equals(1, FlagObject.manager.count($flag == true));
	}

	public function new() {}
}

