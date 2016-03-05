package unit;

import sapo.Context;
import sapo.Populate;
import utest.Assert;

@:keep
@:access(sapo.Populate)
class RandomTests {
	public function test_001_someValidDates()
	{
		var now = Date.now();
		
		for (seed in 40...45) {
			Populate.rnd.setSeed(seed);
			for (i in 0...10) {
				var t = Populate.rndDate(Date.fromTime(i*Date.now().getTime()/10.0)).getTime();
				Assert.isTrue(t > 0.);
				Assert.isTrue(t < now.getTime());
			}
		}
	}
	
	public function setup()
	{
		Context.updateClock();
	}
	public function new() {}
}

