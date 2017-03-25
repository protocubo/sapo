package common;

@:enum abstract EnvVars(String) to String {
	// Location of the main Sapo db (Sqlite)
	var SAPO_DB = "SAPO_DB";
	// Location of the local Sqlite db for the communication system
	var COMN_DB = "COMN_DB";
	// Location of necessary static files
	var STATIC_FILES = "STATIC_FILES";

	// Location for the exported files
	var EXPORTS_PATH = "EXPORTS_PATH";
	// Url to deliver Slack messages to
	var COMN_SLACK_URL = "COMN_SLACK_URL";
	// SendGrid API key
	var COMN_SENDGRID_API_KEY = "COMN_SENDGRID_API_KEY";

	// Channel to send demo Slack messages to
	var COMN_DEMO_SLACK_CHANNEL = "COMN_DEMO_SLACK_CHANNEL";
	// Email `from` field for demo messages
	var COMN_DEMO_EMAIL_AUTHOR = "COMN_DEMO_EMAIL_AUTHOR";
	// Email `to` recipient for demo messages
	var COMN_DEMO_EMAIL_RECIPIENT = "COMN_DEMO_EMAIL_RECIPIENT";

	// Optional Google Analytics tracking id
	// is supplyed, builds will include tracking code
	var GL_ANALYTICS_ID = "GL_ANALYTICS_ID";

	public function getValue()
		return Sys.getEnv(this);

	public function defined()
		return Sys.getEnv(this) != null;

	public function enabled()
	{
		var v = getValue();
		if (v == null)
			return false;
		return
			switch v.toLowerCase() {
			case "": false;
			case "0", "false", "no": false;
			case _: true;
			}
	}
}

