# Environment variables

_Note: at times [`common.EnvVars`](../src/common/EnvVars.hx) might contain more
or less up-to-date information_

At runtime, we depend on the following environment variables for configuration
and passing authentication tokens.  Failing to supply the ones that do not have
default values will make some or all subsystems to fail.

Variable | Meaning | Default
-------- | ------- | -------
SAPO_DB | Location of the main Sapo db (Sqlite) | _required_
COMN_DB | Location of the local Sqlite db for the communication system | _required_
COMN_SLACK_URL | Url to deliver Slack messages to | _required_
COMN_SENDGRID_API_KEY | SendGrid API key | _required_

Additionally, the following variables are used sporadically by some systems;
those systems should handle missing values gracefully, but incorrect values
will still break those systems.

Variable | Meaning | Default
-------- | ------- | -------
 | |

Finally, there are some additional variables used by very specific and
auxiliary executables:

Variable | Meaning | Default
-------- | ------- | -------
COMN_DEMO_SLACK_CHANNEL | Channel to send demo Slack messages to |
COMN_DEMO_EMAIL_AUTHOR | Email `from` field for demo messages |
COMN_DEMO_EMAIL_RECIPIENT | Email `to` recipient for demo messages |

