package sapo;

import common.crypto.Password;
import common.db.MoreTypes;
import sapo.model.*;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

private typedef Groups = {
	surveyors : Group,
	supervisors : Group,
	phoneOperators : Group,
	superUsers : Group
}

private typedef Users = {
	surveyors : Array<User>,
	supervisors : Array<User>,
	phoneOperators : Array<User>,
	superUsers : Array<User>
}

private typedef FakeSurveys = Array<NewSurvey>;

private typedef Tickets = Array<Ticket>;

class Populate {
	static function makeGroups()
	{
		var surveyors = new Group(PSurveyor, new AccessName("pesquisador"), "Pesquisador");
		var supervisors = new Group(PSupervisor, new AccessName("supervisor"), "Supervisor");
		var phoneOperators = new Group(PPhoneOperator, new AccessName("telefonista"), "Telefonista");
		var superUsers = new Group(PSuperUser, new AccessName("super"), "Super usuário");
		for (g in [surveyors, supervisors, phoneOperators, superUsers])
			g.insert();
		return { surveyors : surveyors, supervisors : supervisors,
				phoneOperators : phoneOperators, superUsers : superUsers };
	}

	static function makeUsers(g:Groups)
	{
		var arthur = new User(g.superUsers, new EmailAddress("arthur@sapo"), "Arthur Dent");
		var ford = new User(g.superUsers, new EmailAddress("ford@sapo"), "Ford efect");
		var judite = new User(g.phoneOperators, new EmailAddress("judite@sapo"), "Judite da NET");
		var magentoCol = [ for (i in 0...4) new User(g.supervisors, new EmailAddress('magento.${i+1}@sapo'),
				'Magento Maria #${i+1}') ];
		for (u in [arthur, ford, judite].concat(magentoCol)) {
			u.password = Password.make("secret");
			u.insert();
		}
		var maneCol = [ for (i in 0...20) new User(g.surveyors, new EmailAddress('mane.${i+1}@sapo'),
				'Mané Manê #${i+1}', magentoCol[i%magentoCol.length]) ];
		for (u in maneCol) {
			u.password = Password.make("secret");
			u.insert();
		}
		return { surveyors : maneCol, supervisors : magentoCol,
				phoneOperators : [judite], superUsers : [arthur, ford] };
	}

	static function makeFakeSurveys(u:Users)
	{
		var survey1 = new NewSurvey(u.surveyors[0], "Arthur's house", 945634);
		var survey2 = new NewSurvey(u.surveyors[1], "Betelgeuse, or somewhere near that planet", 6352344);
		survey1.insert();
		survey2.insert();
		var surveyCol = [survey1, survey2];
		return surveyCol;
	}

	static function makeTickets(groups:Groups, users:Users, surveyCol:FakeSurveys)
	{
		var authorCol = users.superUsers.concat(users.supervisors);
		var recipientCol = authorCol.concat(users.phoneOperators);  // TODO create some for groups too
		var ticketCol = [];
		for (i in 0...20) {
			var s = surveyCol[i%surveyCol.length];
			var a = authorCol[i%authorCol.length];
			var r = recipientCol[(recipientCol.length + i)%recipientCol.length];
			TicketModel.open(s, a,
					'Lorem ${s.id} ipsum ${a.name} ${r.name}',
					'Heyy!!  Just letting you know I found an issue with survey ${s.id}',
					r);
		}
		var ticket1 = TicketModel.open(surveyCol[0], users.superUsers[0],
				"Overpass???",
				"Hey, I was distrought over they wanting to build an overpass over my house",
				groups.superUsers);
		TicketModel.addMessage(ticket1, users.superUsers[1], "Don't panic... don't panic...");
		ticketCol.push(ticket1);
		var ticket2 = TicketModel.open(surveyCol[1], users.superUsers[1],
				"About Time...",
				"Time is an illusion, luchtime doubly so.",
				groups.phoneOperators);
		TicketModel.addMessage(ticket2, users.superUsers[0], "Very deep. You should send that in to the Reader's Digest. They've got a page for people like you.");
		ticketCol.push(ticket2);
		return ticketCol;
	}

	@:access(sapo.Context)
	static function makeMore()
	{
		Context.db.request("CREATE VIEW UpdatedSurvey AS SELECT MAX(id) as session_id, old_survey_id, MAX(syncTimestamp) as syncTimestamp FROM Survey GROUP BY old_survey_id");
		Context.surveyGen();
	}

	@:access(sapo.Context)
	public static function reset()
	{
		Context.shutdown();
		if(sys.FileSystem.exists(Context.DBPATH))
			sys.FileSystem.deleteFile(Context.DBPATH);
		Context.init();

		Context.startTransaction();
		try {
			var groups = makeGroups();
			var users = makeUsers(groups);
			var fakeSurveys = makeFakeSurveys(users);
			var tickets = makeTickets(groups, users, fakeSurveys);
			makeMore();
		} catch (e:Dynamic) {
			Context.rollback();
			neko.Lib.rethrow(e);
		}
		Context.commit();
	}
}

