package common.db;

import sys.db.Connection;

@:forward
abstract SaneConnection(Connection) from Connection {
	public inline function commit() this.request("COMMIT");
	public inline function rollback() this.request("ROLLBACK");
}

