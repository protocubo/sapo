package comn.message;

import comn.DeliveryError;
import haxe.io.Input;

private typedef EmailAddress = String;
private typedef FileName = String;
private typedef Cid = String;

typedef SendGridPayload = {
	// Where the email will appear to originate from for your recipient
	from:EmailAddress,
	// Recipients
	to:Array<EmailAddress>,
	// The subject of your email
	subject:String,
	// Plain text content of your email message
	?text:String,
	// HTML content of your email message
	?html:String,
	// Name appended to the from email field
	?fromname:String,
	// Give a name to the recipient
	?toname:Array<String>,
	// TODO Files to be attached
	// ?files:Map<FileName,Input>,
	// TODO Content IDs of the files to be used as inline images.  Content IDs
	// should match the cids used in the HTML markup
	// ?content:Map<FileName,Cid>
	// TODO x-smtapi, cc, ccname, bcc, bccname, replyto, date, headers
}

@:keep
class SendGridEmail implements comn.Message {
#if sapo_comn
	static var url = "https://api.sendgrid.com/api/mail.send.json";
	public function deliver(queue, creds)
	{
		var req = new haxe.Http(url);
		req.setHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setHeader("User-Agent", "sapo");
		req.setParameter("from", payload.from);
		for (i in payload.to)
			req.addParameter("to", i);
		req.setParameter("subject", payload.subject);
		if (payload.text != null)
			req.setParameter("text", payload.text);
		if (payload.html != null)
			req.setParameter("html", payload.html);
		if (payload.fromname != null)
			req.setParameter("fromname", payload.fromname);
		if (payload.toname != null && payload.toname.length == payload.to.length)
			for (i in payload.toname)
				req.addParameter("toname", i);
		req.setHeader("Authorization", "Bearer " + creds.sendGridKey);

		var status = null;
		req.onStatus = function (code) status = code;
		req.onError = function (msg) {
			if (400 <= status && status < 500)
				throw new DeliveryError(EOther, 60, 'errors in the parameters: $msg');
			else
				throw new DeliveryError(EOther, 10, 'api call unsuccessfull: $msg');
		}

		req.request(true);
	}
#end

	var payload:SendGridPayload;

	public function new(payload)
	{
		this.payload = payload;
	}
}

typedef Email = SendGridEmail;

