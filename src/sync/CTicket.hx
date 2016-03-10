package sync;
import common.db.MoreTypes.Privilege;
import sapo.spod.Survey;
import sapo.spod.Ticket;
import sapo.spod.Ticket.TicketSort;
import neko.Random;
import sapo.spod.User;
/**
 * ...
 * @author Caio
 */
class CTicket
{
	public var sysAuthor : User;
	
	public static inline var TICKET_SUBJECT = "AUTOCHECK";
	public static inline var TICKET_MESSAGE = "Hey...listen!";
	
	public function new() 
	{
		//TODO: Definir usuário de sistema
		sysAuthor = User.manager.get(1);
	}
	
	public function sort(user : Int, group : Int, grouplength : Int, survey : Survey)
	{
		var t = TicketSort.manager.select($user_id == user && $group == group, null, false);
		if (t != null)
		{
			var createTicket = false;
			if (grouplength < 10)
			{
				var r = new Random();
				r.setSeed(42);
				
				var v = 2 / (10 - grouplength);
				if (v > r.float())
					createTicket = true;
			}
			
			if (createTicket)
			{
				var t = new Ticket(survey, sysAuthor, TICKET_SUBJECT);
				t.insert();
				var msg = new TicketMessage(t, sysAuthor, TICKET_MESSAGE);
				msg.insert();
				
				var sub = new TicketSubscription(t, Group.manager.select($privilege == Privilege.PPhoneOperator, null ,false));
				sub.insert();
				
				var rec = new TicketRecipient(t, sub);
				rec.insert();
			}
		}
	}
	
	
}