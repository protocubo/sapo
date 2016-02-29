package sapo;

@:deprecated("sapo.Spod.User moved to sapo.spod.User")
typedef User = sapo.spod.User;
@:deprecated("sapo.Spod.Group moved into sapo.spod.User")
typedef Group = sapo.spod.User.Group;
@:deprecated("sapo.Spod.Session moved into sapo.spod.User")
typedef Session = sapo.spod.User.Session;

@:deprecated("sapo.Spod.Ticket moved to sapo.spod.Ticket")
typedef Ticket = sapo.spod.Ticket;
@:deprecated("sapo.Spod.TicketMessage moved into sapo.spod.Ticket")
typedef TicketMessage = sapo.spod.Ticket.TicketMessage;

@:deprecated("sapo.Spod.SurveyStatus moved into sapo.spod.Other")
typedef SurveyStatus = sapo.spod.Other.SurveyStatus;
@:deprecated("sapo.Spod.TicketStatus moved into sapo.spod.Other")
typedef TicketStatus = sapo.spod.Other.TicketStatus;
@:deprecated("sapo.Spod.NewSurvey moved into sapo.spod.Other")
typedef NewSurvey = sapo.spod.Other.NewSurvey;

