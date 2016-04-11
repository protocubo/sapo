package comn.message;

import common.EnvVars;
import common.db.MoreTypes;
import comn.Spod;
import sys.FileSystem;
import sys.db.*;
import sys.io.File;

class DataExport implements comn.Message {
	static var EXPORTS = Sys.getEnv(EXPORTS_PATH);
	var time:HaxeTimestamp;
	var sendTo:EmailAddress;

	function export()
	{
		var buf = new StringBuf();
		buf.add("TODO");
		var data = buf.toString();
		var sha1 = haxe.crypto.Sha1.encode(data);
		var path = haxe.io.Path.join([EXPORTS, sha1 + ".csv"]);
		File.saveContent(path + ".tmp", data);
		FileSystem.rename(path + ".tmp", path);
		return sha1;
	}

#if sapo_comn
	public function deliver(queue, creds)
	{
		if (EXPORTS == null)
			throw 'Missing $EXPORTS_PATH environment variable';
		if (!TableCreate.exists(ExportLog.manager))
			TableCreate.create(ExportLog.manager);

		var sha1 = export();
		var log = new ExportLog(sha1, time);
		log.insert();
		var email = new Email({
			from : "sapo@robrt.io",
			to : [sendTo],
			subject : "[SAPO] Your export is ready",
			text : "To see your data, check " + sha1
		});
		var enq = new LocalEnqueuer(queue);
		enq.enqueue(email);
	}
#end

	public function new(time, sendTo)
	{
		this.time = time;
		this.sendTo = sendTo;
	}
}

