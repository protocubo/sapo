package common;

@:enum abstract EnvVars(String) to String {
	// Location of the local Sqlite db for the communication system
	var COMN_DB = "COMN_DB";

	// Url to deliver Slack messages to
	var COMN_SLACK_URL = "COMN_SLACK_URL";

	// Channel where demo Slack messages should be
	var COMN_DEMO_SLACK_CHANNEL = "COMN_DEMO_SLACK_CHANNEL";
}

