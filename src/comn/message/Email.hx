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
	static var url = "https://api.sendgrid.com/api/mail.send.json";

	var payload:SendGridPayload;

	public function deliver(creds)
	{
		var req = new haxe.Http(url);
		req.setHeader("User-Agent", "sapood");
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
		
		var status = null;
		req.onStatus = function (code) status = code;
		req.onError = function (msg) {
			switch status {
			case 429: throw new DeliveryError(ERateLimited, 10, 'rate limited (429)');
			case _: throw new DeliveryError(EOther, 60, 'unknown: $msg ($status)');
			}
		}

		req.request(true);
	}

	public function new(payload)
	{
		this.payload = payload;
	}
}

typedef Email = SendGridEmail;

