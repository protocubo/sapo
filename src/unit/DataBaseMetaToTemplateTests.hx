package unit;

import common.spod.EnumSPOD;
import utest.Assert;

@:keep
class DataBaseMetaToTemplateTests {
	public function test_001_ReadsomeMeta()
	{
		Assert.equals("Pré-Escolar", sapo.view.Util.enumText(PreEscolar));
		Assert.equals("Até 1 vez por mês", sapo.view.Util.enumText(Vez1Mes));
		Assert.equals("", sapo.view.Util.enumText(Ganguashare));
	}
	public function new() {}
}

