package unit;

import common.spod.EnumSPOD;
import utest.Assert;

@:keep
class DataBaseMetaToTemplateTests {
	public function test_001_ReadsomeMeta()
	{
		Assert.equals("Pré-Escolar", sapo.view.Util.enumText(PreEscolar));
		Assert.equals("Até 1 vez por mês", sapo.view.Util.enumText(Vez1Mes));
		Assert.equals("DEMissing", sapo.view.Util.enumText(common.Dispatch.DispatchError.DEMissing));
		Assert.equals("DEMissingParam",sapo.view.Util.enumText(common.Dispatch.DispatchError.DEMissingParam("nopog")));
		//Assert.raises(sapo.view.Util.enumText.bind(common.Dispatch.DispatchError.DEMissingParam("nopog")));
	}
	public function new() {}
}

