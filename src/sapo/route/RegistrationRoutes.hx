package sapo.route;

import common.crypto.Password;
import common.db.MoreTypes;
import comn.LocalEnqueuer;
import neko.Web;
import sapo.spod.User;
import sys.db.Manager;

class RegistrationRoutes extends AccessControl {
	@authorize(PSuperUser)
	public function doDefault(?args:{ ?activeFilter:String })
	{
		// TODO paginate, orderBy user.name
		if (args == null) args = { };
		var users = new List<User>();
		if(args.activeFilter == "deactivated")
			users = User.manager.search($deactivated_at != null);
		else
			users = User.manager.search($deactivated_at == null);
		Sys.println(sapo.view.Registration.page(users));
	}

	@authorize(PSuperUser)
	public function postEdit(?args:{ ?user:User, ?name:String, ?group:Group, ?supervisor:User })
	{
		// TODO superuser can't disable or change group of other superusers
		// TODO supervisors can't have their group changed (or be disabled) if they have active surveyors
		// TODO disable corresponding UI elements
		// TODO add "selecione" to UI elements
		if (args == null) args = { };
		var u = args.user;

		u.lock();
		u.name = args.name;
		u.group = args.group;
		u.supervisor = (args.supervisor != null? args.supervisor:null);
		u.update();
		Web.redirect("/registration");
	}

	@authorize(PSuperUser)
	public function postAdd(?args:{ ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		Context.db.startTransaction();
		try {
			var u = new User(args.group, new EmailAddress(args.email), args.name, (args.supervisor != null? args.supervisor:null));
			u.insert();

			Token.invalidate(u);
			var t = new Token(u);
			t.insert();

			var email = new comn.message.Email({
				from : "sapo@sapo.robrt.io",
				to : [u.email],
				subject : sapo.view.email.PasswordResetEmail.subject(),
				text : sapo.view.email.PasswordResetEmail.text(t.token)});
			Context.comn.enqueue(email);
		} catch (e:Dynamic) {
			Context.db.rollback();
			neko.Lib.rethrow(e);
		}
		Context.db.commit();
		Web.redirect("/registration");
	}

	@authorize(PSuperUser)
	public function postDeactivate(?args:{ ?user:User })
	{
		if (args == null) args = { };
		args.user.lock();
		args.user.deactivated_at = Context.now;
		args.user.update();
		Web.redirect("/registration");
	}

	public function new() {}
}
