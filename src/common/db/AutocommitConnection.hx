package common.db;

import sys.db.Connection;

@:forward
abstract AutocommitConnection(Connection) from Connection {
	public inline function commit() this.request("COMMIT");
	public inline function rollback() this.request("ROLLBACK");
}

