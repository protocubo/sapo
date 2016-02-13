# Environment variables

At runtime, we depend on the following environment variables for configuration
and passing authentication tokens.  Failing to supply the ones that do not have
default values will make some or all subsystems to fail.

Variable | Meaning | Default
-------- | ------- | -------
COMN_DB | Location of the local Sqlite db for the communication system | _required_
COMN_SLACK_URL | Url to deliver Slack messages to | _required_

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
COMN_DEMO_SLACK_CHANNEL | Channel where demo Slack messages should be  | 

**Note**: `common.EnvVars` might contain more up-to-date information.


