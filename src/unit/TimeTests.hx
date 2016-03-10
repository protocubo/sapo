package unit;

import sapo.Context;
import utest.Assert;

class TimeTests {
	public function test_000_stuff()
	{
		var timeNow = Date.now().getTime();
		var getTimeOfDayNow = Sys.time()*1e3;
		Assert.floatEquals(timeNow, getTimeOfDayNow, 2e3);

		Context.updateClock();
		Assert.floatEquals(timeNow, Context.now, 2e3);
	}

	public function new() {}
}

