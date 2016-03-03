package sapo;

import common.Dispatch;
import common.spod.EnumSPOD;
import common.spod.Modo;
import common.spod.Ponto;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import common.spod.statics.UF;
import sapo.spod.Survey;
import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import common.spod.InitDB;
import sapo.route.AccessControl;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;
import sys.db.*;

class Context {
	static var DBPATH = Sys.getEnv("SAPO_DB");

	public static var version(default,null) = { commit : Version.getGitCommitHash() }
	public static var loop(default,null):Context;
	public static var db(default,null):common.db.AutocommitConnection;

	var dispatch:Dispatch;

	public var now(default,null):HaxeTimestamp;
	public var uri(default,null):String;
	public var params(default,null):Map<String,String>;
	public var method(default,null):String;

	public var session(default,null):Null<Session>;
	public var user(default,null):Null<User>;
	public var group(default,null):Null<Group>;
	public var privilege(default,null):Null<Privilege>;

	function new(now, uri:String, params:Map<String, String>, method:String, session:Null<Session>)
	{
		this.now = now;
		this.uri = uri;
		this.params = params;
		dispatch = new Dispatch(uri, params, method);

		if (session == null)
			return;
		if (session.expired(now)) {
			session.expire();
			session.update();
			return;
		}
		this.session = session;
		this.user = session.user;
		this.group = user.group;
		this.privilege = group.privilege;
	}

	static function dbInit()
	{
		var managers:Array<Manager<Dynamic>> = [
			Group.manager,
			NewSurvey.manager,
			Session.manager,
			Ticket.manager,
			TicketMessage.manager,
			TicketSubscription.manager,
			User.manager
		];
		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);
	}

	public static function resetMainDb()
	{
		if (Manager.cnx != null) {
			Manager.cnx.close();
			Manager.cnx = null;
		}
		if(sys.FileSystem.exists(DBPATH))
			sys.FileSystem.deleteFile(DBPATH);
		init();

		startTransaction();
		try {
			// system groups
			var surveyors = new Group(PSurveyor, new AccessName("pesquisador"), "Pesquisador");
			var supervisors = new Group(PSupervisor, new AccessName("supervisor"), "Supervisor");
			var phoneOperators = new Group(PPhoneOperator, new AccessName("telefonista"), "Telefonista");
			var superUsers = new Group(PSuperUser, new AccessName("super"), "Super usuário");
			for (g in [surveyors, supervisors, phoneOperators, superUsers]) {
				g.insert();
				var gu = new User(g, new EmailAddress('${g.group_name}@sapo'), "*", true);
				gu.insert();
			}

			// users
			var arthur = new User(superUsers, new EmailAddress("arthur@sapo"), "Arthur Dent");
			var ford = new User(superUsers, new EmailAddress("ford@sapo"), "Ford efect");
			var judite = new User(phoneOperators, new EmailAddress("judite@sapo"), "Judite da NET");
			var magentoCol = [ for (i in 0...4) new User(supervisors, new EmailAddress('magento.${i+1}@sapo'), 'Magento Maria #${i+1}') ];
			for (u in [arthur, ford, judite].concat(magentoCol)) {
				u.password = Password.make("secret");
				u.insert();
			}
			var maneCol = [ for (i in 0...20) new User(surveyors, new EmailAddress('mane.${i+1}@sapo'), 'Mané Manê #${i+1}', magentoCol[i%magentoCol.length]) ];
			for (u in maneCol) {
				u.password = Password.make("secret");
				u.insert();
			}

			// some surveys
			var survey1 = new NewSurvey(maneCol[0], "Arthur's house", 945634);
			var survey2 = new NewSurvey(maneCol[1], "Betelgeuse, or somewhere near that planet", 6352344);
			survey1.insert();
			survey2.insert();
			var surveyCol = [survey1, survey2];

			// some tickets
			var authorCol = [arthur, ford].concat(magentoCol);
			var recipientCol = authorCol.concat([judite]).concat(Lambda.array(
					User.manager.search($isGroup && ($group == phoneOperators || $group == superUsers))));
			var ticketCol = [];
			for (i in 0...20) {
				var s = surveyCol[i%surveyCol.length];
				var a = authorCol[i%authorCol.length];
				var r = recipientCol[(recipientCol.length + i)%recipientCol.length];
				var t = new Ticket(s, a, r, 'Lorem ${s.id} ipsum ${a.name} ${r.name}');
				t.insert();
				var m = new TicketMessage(t, a, 'Heyy!!  Just letting you know I found an issue with survey ${s.id}');
				m.insert();
				var ts = new TicketSubscription(t, a);
				ts.insert();
			}
			var ticket1 = new Ticket(survey1, arthur, ford, "Overpass???");
			ticket1.insert();
			new TicketMessage(ticket1, arthur, "Hey, I was distrought over they wanting to build an overpass over my house").insert();
			new TicketMessage(ticket1, ford, "Don't panic... don't panic...").insert();
			var ticket2 = new Ticket(survey2, ford, arthur, "About Time...");
			ticket2.insert();
			new TicketMessage(ticket2, ford, "Time is an illusion, lunchtime doubly so. ").insert();
			new TicketMessage(ticket2, arthur, "Very deep. You should send that in to the Reader's Digest. They've got a page for people like you.").insert();
			
			surveyGen();
		} catch (e:Dynamic) {
			rollback();
			neko.Lib.rethrow(e);
		}
		commit();
	}
	
	static function surveyGen()
	{
		var surveyorgroup = Group.manager.select($privilege == Privilege.PSurveyor, null, false);
		var supervisorGroup = Group.manager.select($privilege == Privilege.PSupervisor, null, false);
		var supervisor = new User(supervisorGroup, new EmailAddress("Sup@sup.com.br"), "Supervisor5000");
		var i = 0;
		
		var userarr = [];
		while (i < 5)
		{
			var surveyor = new User(surveyorgroup, new EmailAddress("Bla" + i + "@blabla.com.br"), "Bla " + i, false, supervisor);
			surveyor.password = Password.make("secret");
			surveyor.insert();
			
			userarr.push(surveyor);
			
			i++;
		}
		
		i = 0;
		var group = [];
		while (i < 1000)
		{
			var s = new Survey();
			s.user_id = Std.random(userarr.length);
			s.isRestored = false;
			s.isValid = false;
			s.lastPageVisited = "END";
			s.endereco_id = Std.random(9999);
			s.estadoPesquisa = EstadoPesquisa.Concluida;
			s.bairro = "Asa Centro Oeste";
			s.logradouro = "Rua GWD";
			s.numero = "5000";
			s.lote = "Lote 123";
			s.macrozona = "Macro 5000";
			s.municipio = "Brasília";
			s.old_survey_id = i;
			s.pin = "ASD-Qer3-qwee";
			s.syncTimestamp = Date.now().getTime();
			s.tentativa_id = 1;
			s.checkCT = false;
			s.checkSupervisor = false;
			s.checkSuper = false;
			s.date_create = DateTools.delta(Date.now(), -1000.0 * 60 * 60 * 24 * Std.random(5));
			s.date_started = s.date_create;
			s.date_finished = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * Std.random(5));
			s.date_completed = s.date_finished;
			var g = group[s.user_id];
			if (g == null)
				group[s.user_id] = [1, 0];
			var group1 = group[s.user_id][0];
			var count = group[s.user_id][1];
			if (count < 10)
				group[s.user_id] = [group1, count + 1];
			else
				group[s.user_id] = [group1 + 1, 1];
			s.group = group[s.user_id][0];
			s.insert();
			
			var f = new Familia();
			f.aguaEncanada = Type.createEnumIndex(AguaEncanada, Std.random(2));
			f.anoVeiculoMaisRecente = Type.createEnumIndex(AnoVeiculoMaisRecente, Std.random(8));
			f.banheiros = Std.random(3);
			f.bicicletas = Std.random(1);
			f.condicaoMoradia = Type.createEnumIndex(CondicaoMoradia, Std.random(7));
			f.date = DateTools.delta(s.date_create, 1000 * 60 * Std.random(60));
			f.empregadosDomesticos = Type.createEnumIndex(EmpregadosDomesticos, Std.random(4));
			f.isDeleted = false;
			f.isEdited = 0;
			f.motos = Std.random(3);
			f.nomeContato = "Red Herring " + i;
			f.numeroResidentes = Std.random(4);
			f.ocupacaoDomicilio = Type.createEnumIndex(OcupacaoDomicilio, Std.random(4));
			f.old_id = i;
			f.old_survey_id = s.old_survey_id;
			f.quartos = Std.random(4);
			f.recebeBolsaFamilia = randomBool();
			f.rendaDomiciliar = Type.createEnumIndex(RendaDomiciliar, Std.random(12));
			f.ruaPavimentada_id = randomBool();
			f.survey = s;
			f.syncTimestamp = s.syncTimestamp;
			f.telefoneContato = "9999-9999";
			f.tentativa_id = 1;
			f.tipoImovel = Type.createEnumIndex(TipoImovel, Std.random(7));
			f.tvCabo_id = randomBool();
			f.vagaPropriaEstacionamento_id = randomBool();
			f.veiculos = Std.random(4);
			f.insert();
			
			var j = 0;
			while (j < f.numeroResidentes)
			{
				var m = new Morador();
				m.atividadeMorador = Type.createEnumIndex(AtividadeMorador, Std.random(15));
				m.date = DateTools.delta(f.date, 1000 * 60 * Std.random(60));
				m.familia = f;
				m.genero_id = Std.random(1);
				m.grauInstrucao = Type.createEnumIndex(GrauInstrucao, Std.random(12));
				m.idade = Type.createEnumIndex(Idade, Std.random(14));
				m.isDeleted = false;
				m.isEdited = 0;
				m.motivoSemViagem = Type.createEnumIndex(MotivoSemViagem, Std.random(3));
				m.nomeMorador = "Zacarias José " + i;
				m.old_id = i + j;
				m.old_survey_id = s.old_survey_id;
				m.portadorNecessidadesEspeciais = Type.createEnumIndex(PortadorNecessidadesEspeciais, Std.random(7));
				m.possuiHabilitacao_id = randomBool();
				m.proprioMorador_id = randomBool();
				m.quemResponde = null;
				m.setorAtividadeEmpresaPrivada = Type.createEnumIndex(SetorAtividadeEmpresaPrivada, Std.random(8)); 
				m.setorAtividadeEmpresaPublica = Type.createEnumIndex(SetorAtividadeEmpresaPublica, Std.random(4));
				m.situacaoFamiliar = Type.createEnumIndex(SituacaoFamiliar, Std.random(10));
				m.survey = s;
				m.syncTimestamp = s.syncTimestamp;
				m.insert();
				
				var n = 0;
				while (n < Std.random(4))
				{
					var p = new Ponto();
					p.city_id = Std.random(10000);
					p.complement_id = Std.random(1000);
					p.complement_two_id = Std.random(1000);
					p.complement2_str = "random";
					p.copiedFrom = null;
					p.date = DateTools.delta(m.date, 1000 * 60 * Math.random());
					p.isDeleted = false;
					p.isEdited = 0;
					p.isPontoProx = randomBool();
					p.morador = m;
					p.motivo = Type.createEnumIndex(Motivo, Std.random(14));
					p.motivoOutraPessoa = Type.createEnumIndex(Motivo, Std.random(14));
					p.old_id = Std.random(4);
					p.old_survey_id = s.old_survey_id;
					p.pontoProx = null;
					p.ref = null;
					p.ref_str = "Random place ";
					p.regadm_id = Std.random(9999);
					p.street_id = Std.random(9999);
					p.survey = s;
					p.syncTimestamp = m.syncTimestamp;
					p.tempo_chegada = Std.random(24)  + ":" + Std.random(60);
					p.tempo_saida = Std.random(24) + ":" + Std.random(60);
					p.uf = UF.manager.get(1);
					p.insert();
					
					var o = 0;
					while ( o < Std.random(2) && n%2 == 0)
					{
						var mo = new Modo();
						mo.date = DateTools.delta(p.date, 1000 * 60 * Std.random(40));
						mo.estacaoDesembarque = EstacaoMetro.manager.get(Std.random(20));
						mo.estacaoEmbarque = EstacaoMetro.manager.get(Std.random(20));
						mo.firstpoint = Ponto.manager.get(Manager.cnx.lastInsertId());
						mo.secondpoint = p;
						mo.formaPagamento = Type.createEnumIndex(FormaPagamento, Std.random(7));
						mo.isDeleted = false;
						mo.isEdited = 0;
						mo.linhaOnibus = LinhaOnibus.manager.get(Std.random(50));
						mo.meiotransporte = Type.createEnumIndex(MeioTransporte, Std.random(16));
						mo.morador = m;
						mo.naoRespondeu = randomBool();
						mo.naoSabe = randomBool();
						mo.old_id = i + j + o;
						mo.old_morador_id = m.old_id;
						mo.old_survey_id = s.old_survey_id;
						mo.survey = s;
						mo.syncTimestamp = s.syncTimestamp;
						mo.tipoEstacionamento = Type.createEnumIndex(TipoEstacionamento, Std.random(8));
						mo.valorViagem = Math.random() * Std.random(40);
						mo.insert();
						
						
						o++;
					}
					n++;
				}
				j++;
			}
			
			if (i % 100 == 0)
				Manager.cnx.commit();
				
			i++;
			
		}
		
		Manager.cnx.commit();
		
	}
	static function randomBool() : Null<Bool>
	{
		var v = Std.random(3);
		return ((v == 2) ? null : (v == 1));
	}
	public static function init()
	{
		InitDB.run();
		dbInit();
		db = Manager.cnx;
	}

	public static function startTransaction()
		db.request("BEGIN");

	public static function commit()
		db.request("COMMIT");

	public static function rollback()
		db.request("ROLLBACK");

	public static function shutdown()
	{
		if (Manager.cnx == null) return;
		Manager.cnx.close();
		db = Manager.cnx = null;
	}

#if !sapo_sync
	public static function iterate()
	{
		var uri = Web.getURI();
		var params = Web.getParams();
		var method = Web.getMethod();

		// treat visibly empty params as missing
		var cparams = [ for (k in params.keys()) if (StringTools.trim(params.get(k)).length > 0) k => params.get(k) ];

		var key = Session.COOKIE_KEY;
		var cookies = Web.getAllCookies();
		if (cookies.exists(key) && cookies[key].length > 1)
			trace('WARNING multiple (${cookies[key].length}) values for cookie ${key}; we can\'t handle that yet');
		var sid = Web.getCookies()[key];  // FIXME
		var session = Session.manager.get(sid);

		loop = new Context(Date.now(), uri, cparams, method, session);

		trace(loop.session);
		if (loop.session != null) trace(loop.session.expires_at.toDate());
		if (loop.session != null) trace(loop.session.expired());
		if (loop.session != null && loop.session.expired_at != null) trace(loop.session.expired_at.toDate());

		// log if we're loosing any params
		var aparams = Web.getAllParams();
		for (p in aparams.keys())
			if (aparams[p].length > 1)
				trace('WARNING multiple (${aparams[p].length}) values for param $p; we can\'t handle that yet');

		loop.dispatch.onMeta = AccessControl.onDispatchMeta;
		try {
			loop.dispatch.dispatch(new sapo.route.RootRoutes());
		} catch (e:AccessControlError) {
			Context.shutdown();
			trace('Access control error: $e');
			var url = Web.getURI();
			if (Web.getMethod().toLowerCase() == "get")
				url += "?" + [
					for (k in Web.getParams().keys())
						'${StringTools.urlEncode(k)}=${StringTools.urlEncode(Web.getParams().get(k))}'
				].join("&");
			Web.redirect('/login?redirect=${StringTools.urlEncode(url)}');
		}
	}
#end
}

