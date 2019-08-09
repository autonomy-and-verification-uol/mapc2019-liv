package env;

import java.awt.Point;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.logging.Logger;


import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.StringTerm;
import jason.asSyntax.StringTermImpl;


public class TeamArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(TeamArtifact.class.getName());

	private static Map<String, String>  agentNames 	 	= new HashMap<String, String>();
	private static Map<String, String>  agentRoles 	 	= new HashMap<String, String>();

	private static Map<Integer, Set<String>> actionsByStep   = new HashMap<Integer, Set<String>>();
	
	private Map<String, Set<Point>>  map1 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map2 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map3 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map4 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map5 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map6 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map7 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map8 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map9 	 	= new HashMap<String, Set<Point>>();
	private Map<String, Set<Point>>  map10 	 	= new HashMap<String, Set<Point>>();
	
	private Map<String, Map<String, Set<Point>>> agentmaps = new HashMap<String, Map<String, Set<Point>>>();
	

	
	void init(){
		logger.info("Team Artifact has been created!");
		agentmaps.put("agent1",map1);
		agentmaps.put("agent2",map2);
		agentmaps.put("agent3",map3);
		agentmaps.put("agent4",map4);
		agentmaps.put("agent5",map5);
		agentmaps.put("agent6",map6);
		agentmaps.put("agent7",map7);
		agentmaps.put("agent8",map8);
		agentmaps.put("agent9",map9);
		agentmaps.put("agent10",map10);
	}
		
	@OPERATION
	void addServerName(String agent, String agentServer){
		agentNames.put(agent,agentServer);
	}
	
	@OPERATION
	void getServerName(String agent, OpFeedbackParam<String> agentServer){
		agentServer.set(agentNames.get(agent));
	}
	
	@OPERATION
	void addRole(String agent, String role){
		agentRoles.put(agent,role);
	}
	
	public static String getAgentRole(String agent) {
		return agentRoles.get(agent);
	}
	
	@OPERATION
	void updateMap(String name, String type, int x, int y) {
		Point p = new Point(x, y);
		if (!agentmaps.get(name).containsKey(type)) {
			Set<Point> set = new HashSet<Point>();
			set.add(p);
			agentmaps.get(name).put(type, set);
		}
		else {
			agentmaps.get(name).get(type).add(p);
		}
	}
	
	@OPERATION 
	void getDispensers(String name, OpFeedbackParam<Literal[]> dispensers){
		List<Literal> things 		= new ArrayList<Literal>();
		for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
//		    logger.info(name+"  :   "+entry.getKey() + " = " + entry.getValue());
			StringTerm type = new StringTermImpl(entry.getKey());
			for (Point p : entry.getValue()) {
				Literal literal = ASSyntax.createLiteral("dispenser");
				NumberTerm x = new NumberTermImpl(p.x);
				NumberTerm y = new NumberTermImpl(p.y);
				literal.addTerm(type);
				literal.addTerm(x);
				literal.addTerm(y);
				things.add(literal);
			}
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		dispensers.set(arraythings);
	}
	
	@OPERATION
	void mergeMaps(int Ax, int Ay, String Adispensers) {
//			, int Bx, int By, String[] Bdispensers) {
		logger.info("Agent A dispensers "+Adispensers);
//		logger.info("Agent B dispensers "+Bdispensers);
	}
	
	
	@OPERATION
	void clearRound() {
		agentNames.clear();
		agentRoles.clear();
		actionsByStep.clear();
		this.init();
	}
	
	@OPERATION
	void chosenAction(int step) {
		String agent = getCurrentOpAgentId().getAgentName();
		
		Set<String> agents = actionsByStep.remove(step);
		if (agents == null)
			agents = new HashSet<String>();
		
		if (!agents.contains(agent)) {
			agents.add(agent);
			actionsByStep.put(step, agents);
			
			if (this.getObsPropertyByTemplate("chosenActions", step,null) != null)
				this.removeObsPropertyByTemplate("chosenActions", step, null);
			this.defineObsProperty("chosenActions", step, agents.toArray());
			
//			clean belief
			if (actionsByStep.containsKey(step-3)) {
				actionsByStep.remove(step-3);
				this.removeObsPropertyByTemplate("chosenActions", step-3, null);
			}
		}	
	}
	
}
