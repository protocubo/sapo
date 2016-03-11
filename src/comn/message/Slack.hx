package comn.message;

import comn.DeliveryError;

typedef SlackMarkdown = String;  // todo escaping, links etc.

typedef SlackAttachmentField = {
	title : String,
	value : SlackMarkdown,
	?short : Bool
}

typedef SlackAttachment = {
	fallback : String,
	?color : String,  // rgb string
	?pretext : String,
	?author_name : String,
	?author_link : String,
	?author_icon : String,
	title : String,
	?title_link : String,
	?text : SlackMarkdown,
	?fields : Array<SlackAttachmentField>,
	?image_url : String,
	?thumb_url : String
}

typedef SlackPayload = {
	text : SlackMarkdown,
	?username : String,
	?icon_emoji : String,
	?channel : String,  // channel (#) or user (@)
	?attachments : Array<SlackAttachment>
}

@:keep
class Slack implements comn.Message {
#if hxssl
	public function deliver(queue, creds)
	{
		var req = new haxe.Http(creds.slackUrl);
		req.setHeader("Content-Type", "application/json");
		req.setHeader("User-Agent", "sapood");
		req.setPostData(haxe.Json.stringify(payload));

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
#end

	var payload:SlackPayload;

	public function new(payload)
	{
		this.payload = payload;
	}
}

