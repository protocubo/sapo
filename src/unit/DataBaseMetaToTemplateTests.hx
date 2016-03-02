package unit;

import common.spod.EnumSPOD;
import sapo.spod.Survey;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import common.spod.statics.Referencias;
import common.spod.statics.UF;
import haxe.rtti.Meta;
import utest.Assert;

@:keep
class DataBaseMetaToTemplateTests {
	public function test_001_ReadsomeMeta()
	{
		var v = NaoRespondeu;
		var e = Type.getEnum(v);
		var cons = Type.enumConstructor(v);

		var meta = haxe.rtti.Meta.getFields(e);
		var cnMeta = Reflect.field(meta, cons);
		var tmeta:Array<Dynamic> = cnMeta.tt;
		for (text in tmeta) {
			if (Type.getClassName(Type.getClass(text)) != "String")
				trace (' $text  not a string!');
			else
				trace('v to text = $text');
		}
	}
	public function new() {}
}

