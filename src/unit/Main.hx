package unit;

class Main {
	static function main()
	{
		var runner = new utest.Runner();
		runner.addCase(new PasswordTests());

		utest.ui.Report.create(runner);

		runner.run();
	}
}

