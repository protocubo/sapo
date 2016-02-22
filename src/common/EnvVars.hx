package common;

@:enum abstract EnvVars(String) to String {
	// Location of the main Sapo db (Sqlite)
	var SAPO_DB = "SAPO_DB";

	// Location of the local Sqlite db for the communication system
	var COMN_DB = "COMN_DB";

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
}

