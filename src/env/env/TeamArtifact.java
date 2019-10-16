package env;

import java.awt.Point;
import java.util.HashMap;
import java.util.HashSet;
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
import jason.util.Pair;
import jason.asSyntax.Atom;


public class TeamArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(TeamArtifact.class.getName());

	private static Map<String, String>  agentNames 	 	= new HashMap<String, String>();
	
	private static Map<String, String>  agentAvailable 	 	= new HashMap<String, String>();

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
	
	private int maxPlanners = 5;
	private int planners;
	
	private String firstToStop;
	
	private int pos;
	private String goalAgent;
	private Integer targetGoalX;
	private Integer targetGoalY;
	private String goalSide;
	private List<Point> retrieversAvailablePositions = new ArrayList<>();
	
	private static List<Pair<String, String>> ourBlocks = new ArrayList<>();
	
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
		planners = 0;
		firstToStop = null;
		goalAgent = null;
		targetGoalX = null;
		targetGoalY = null;
		goalSide = null;
		pos  = 10;
	}
	
	@OPERATION
	void firstToStop(String agent, OpFeedbackParam<Boolean> flag){
		if(this.firstToStop != null) {
			flag.set(false);
		}
		else {
			this.firstToStop = agent;
			flag.set(true);
		}
		logger.info("!!!! First to stop "+firstToStop);
	}
	
	@OPERATION
	void callPlanner(OpFeedbackParam<Boolean> flag){
		if(this.planners+1 <= this.maxPlanners) {
			this.planners++;
			flag.set(true);
		}
		else {
			flag.set(false);
		}
	}
	
	@OPERATION
	void plannerDone(){
		this.planners--;
	}
	
	
	@OPERATION
	void joinRetrievers(OpFeedbackParam<String> flag){
			flag.set("retriever");
	}
	
	
	@OPERATION
	void getTargetGoal(OpFeedbackParam<String> agent, OpFeedbackParam<Integer> x, OpFeedbackParam<Integer> y, OpFeedbackParam<String> side){
		if(goalAgent == null) {
			return;
		}
		agent.set(goalAgent);
		x.set(targetGoalX);
		y.set(targetGoalY);
		side.set(goalSide);
	}
	
	@OPERATION
	void setTargetGoal(int pos, String agent, int x, int y, String side){
		if(pos <= this.pos) {
			this.goalAgent = agent;
			this.targetGoalX = x;
			this.targetGoalY = y;
			this.pos = pos;
			this.goalSide = side;
		}
	}
	
	@OPERATION
	void setTargetGoal(int pos, String agent, int x, int y){
		if(pos <= this.pos) {
			this.goalAgent = agent;
			this.targetGoalX = x;
			this.targetGoalY = y;
			this.pos = pos;
		}
	}
	
	
	@OPERATION
	void updateRetrieverAvailablePos(int x, int y) {
		for(Point p: this.retrieversAvailablePositions) {
			p.x += x;
			p.y += y;
		}
	}
	
	
	@OPERATION
	void initRetrieverAvailablePos(String name) {
		logger.info("initRetrieversAvailablePos");
		if(this.targetGoalX == null | this.targetGoalY == null) return;
		this.retrieversAvailablePositions.clear();
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(targetGoalX == pp.x && targetGoalY == pp.y) {
						logger.info("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
						logger.info(((OriginPoint) pp).retrievers+"");
						for(Point retriever : ((OriginPoint) pp).retrievers) {
							logger.info("[" + name + "]" + "( " + retriever.x + ", " + retriever.y + " ) retriever added");
							this.retrieversAvailablePositions.add(retriever);
						}
						return;
					}
				}
			}
		}
	}
		
	@OPERATION
	void getRetrieverAvailablePos(OpFeedbackParam<Integer> x, OpFeedbackParam<Integer> y) {
		logger.info("Available retriever positions: ");
		for(Point p : this.retrieversAvailablePositions) {
			logger.info("( "+ p.x + ", " + p.y + " )");
		}
		if(!this.retrieversAvailablePositions.isEmpty()) {
			x.set(this.retrieversAvailablePositions.get(0).x);
			y.set(this.retrieversAvailablePositions.get(0).y);
			this.retrieversAvailablePositions.remove(0);
		}
	}
	
	@OPERATION
	void addRetrieverAvailablePos(int x, int y) {
		logger.info("(" + x + ", " + y + ") is now a retriever available position");
		this.retrieversAvailablePositions.add(new Point(x, y));
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
	void evaluateOrigin(String name, int x, int y, String evaluation) {
		//if(evaluation.equals("boh")) return;
		logger.info("evaluateOrigin(" + name + ", " + x + ", " + y + ", " + evaluation + ")");
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(x == pp.x && y == pp.y) {
						if(pp instanceof OriginPoint) {
							if(((OriginPoint) pp).evaluated.equals("boh")) {
								((OriginPoint) pp).evaluated = evaluation;
							} 
							return;
						}
						agentmaps.get(name).get(key).remove(pp);
						agentmaps.get(name).get(key).add(new OriginPoint(x, y, evaluation));
						return;
					}
				}
			}
		}
		logger.info("not found it");
	}
	
	@OPERATION
	void evaluateOrigin(String name, int x, int y, String evaluation, int maxPosS, int maxPosW, int maxPosE) {
		//if(evaluation.equals("boh")) return;
		logger.info("evaluateOrigin(" + name + ", " + x + ", " + y + ", " + evaluation + ")");
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(x == pp.x && y == pp.y) {
						if(pp instanceof OriginPoint) {
							if(((OriginPoint) pp).evaluated.equals("boh")) {
								((OriginPoint) pp).evaluated = evaluation;
								((OriginPoint) pp).maxPosS = maxPosS;
								((OriginPoint) pp).maxPosW = maxPosW;
								((OriginPoint) pp).maxPosE = maxPosE;
							} 
							return;
						}
						agentmaps.get(name).get(key).remove(pp);
						agentmaps.get(name).get(key).add(new OriginPoint(x, y, evaluation, maxPosS, maxPosW, maxPosE));
						return;
					}
				}
			}
		}
		logger.info("not found it");
	}
	
	@OPERATION
	void addScoutToOrigin(String name, int originX, int originY, int scoutX, int scoutY) {
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(pp instanceof OriginPoint & originX == pp.x && originY == pp.y) {
						((OriginPoint) pp).scouts.add(new Point(scoutX, scoutY));
						return;
					}
				}
			}
		}
	}
	
	@OPERATION
	void addRetrieverToOrigin(String name, int originX, int originY, int retrieverX, int retrieverY) {
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(pp instanceof OriginPoint & originX == pp.x && originY == pp.y) {
						logger.info("[" + name + "]" + "(" + retrieverX + ", " + retrieverY + ") retriever added to cluster " + key);
						((OriginPoint) pp).retrievers.add(new Point(retrieverX, retrieverY));
						return;
					}
				}
			}
		}
		logger.info("[" + name + "]" + "addRetrieverToOrigin has not add anything");
	}
	
	@OPERATION
	void updateGoalMap(String name, int x, int y, OpFeedbackParam<String> clusterInserterIn, OpFeedbackParam<Boolean> isANewCluster) {
		Point p = new Point(x, y);
		logger.info("[" + name + "]: Try to add goal (" + x + ", " + y + ")");
		double minDistance = 5;
		String myCluster = null;
		int id = 0;
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				double distance = 0;
				for(Point pp : agentmaps.get(name).get(key)) {
					if(p.x == pp.x && p.y == pp.y) {
						return;
					}
					distance += Math.abs(p.x-pp.x) + Math.abs(p.y-pp.y);
					//System.out.println("Point (" + p.x + ", " + p.y + ") distance from (" + pp.x + ", " + pp.y + "):" + (Math.abs(p.x-pp.x) + Math.abs(p.y-pp.y)));
				}
				distance = distance / agentmaps.get(name).get(key).size();
				if(distance < minDistance) {
					minDistance = distance;
					myCluster = key;
				}
				id++;
			}
		}
		if(myCluster == null) {
			//logger.info("ID: " + id);
			Set<Point> set = new HashSet<Point>();
			//set.add(new OriginPoint(x, y));
			set.add(p);
			agentmaps.get(name).put("goal_" + id, set);
			clusterInserterIn.set("goal_" + id);
			isANewCluster.set(true);
			//logger.info("[" + name + "]" + " added point (" + p.x + ", " + p.y + ") to cluster " + agentmaps.get(name).get("goal_" + id) + " because distance is: " + minDistance);
		} else {
			//logger.info("[" + name + "]" + " added point (" + p.x + ", " + p.y + ") to cluster " + agentmaps.get(name).get(myCluster) + " because distance is: " + minDistance);
			clusterInserterIn.set(myCluster);
			isANewCluster.set(false);
			agentmaps.get(name).get(myCluster).add(p);
		}
	}
	
	@OPERATION
	void updateMap(String name, String type, int x, int y) {
		Point p = new Point(x, y);
		if(!type.startsWith("goal_")) {
			if (!agentmaps.get(name).containsKey(type)) {
				Set<Point> set = new HashSet<Point>();
				set.add(p);
				agentmaps.get(name).put(type, set);
			}
			else {
				agentmaps.get(name).get(type).add(p);
			}
		}
	}
	
	private static class OriginPoint extends Point{
		private String evaluated = "boh";
		private List<Point> scouts = new ArrayList<>();
		private List<Point> retrievers = new ArrayList<>();
		private int maxPosS;
		private int maxPosW;
		private int maxPosE;
		
		public OriginPoint(int x, int y, String evaluated) {
			super(x, y);
			this.evaluated = evaluated;
		}
		
		public OriginPoint(int x, int y, String evaluated, int maxPosS, int maxPosW, int maxPosE) {
			super(x, y);
			this.evaluated = evaluated;
			this.maxPosS = maxPosS;
			this.maxPosW = maxPosW;
			this.maxPosE = maxPosE;
		}
		// nothing different to add for now
	}
	
	@OPERATION 
	void getMapSize(String name, OpFeedbackParam<Integer> size){
		size.set(agentmaps.get(name).values().stream().mapToInt(Set::size).sum());
	}
	
	@OPERATION 
	void getDispensers(String name, OpFeedbackParam<Literal[]> dispensers){
		List<Literal> things = new ArrayList<Literal>();
		for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
			if (!entry.getKey().startsWith("goal_")) {
	//		    logger.info(name+"  :   "+entry.getKey() + " = " + entry.getValue());
				Atom type = new Atom(entry.getKey());
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
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		dispensers.set(arraythings);
	}
	
	@OPERATION 
	void getGoalClusters(String name, OpFeedbackParam<Literal[]> clusters){
		List<Literal> things 		= new ArrayList<Literal>();
		for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
			if (entry.getKey().startsWith("goal_")) {
	//		    logger.info(name+"  :   "+entry.getKey() + " = " + entry.getValue());
				Literal cluster = ASSyntax.createLiteral("cluster");
				cluster.addTerm(ASSyntax.createAtom(entry.getKey()));
				List<Literal> goals = new ArrayList<Literal>();
				for (Point p : entry.getValue()) {
					Literal literal = null;
					if(p instanceof OriginPoint) {
						literal = ASSyntax.createLiteral("origin");
						literal.addTerm(new Atom(((OriginPoint) p).evaluated));
					} else {
						literal = ASSyntax.createLiteral("goal");
					}
					NumberTerm x = new NumberTermImpl(p.x);
					NumberTerm y = new NumberTermImpl(p.y);
					literal.addTerm(x);
					literal.addTerm(y);
					goals.add(literal);
				}
				cluster.addTerm(ASSyntax.createList(goals.toArray(new Literal[goals.size()])));
				things.add(cluster);
			}
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		clusters.set(arraythings);
	}
	
	@OPERATION 
	void getGoalClustersWithScouts(String name, OpFeedbackParam<Literal[]> clusters){
		List<Literal> things 		= new ArrayList<Literal>();
		for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
			if (entry.getKey().startsWith("goal_")) {
	//		    logger.info(name+"  :   "+entry.getKey() + " = " + entry.getValue());
				Literal cluster = ASSyntax.createLiteral("cluster");
				cluster.addTerm(ASSyntax.createAtom(entry.getKey()));
				List<Literal> goals = new ArrayList<Literal>();
				for (Point p : entry.getValue()) {
					Literal literal = null;
					if(p instanceof OriginPoint) {
						literal = ASSyntax.createLiteral("origin");
						literal.addTerm(new Atom(((OriginPoint) p).evaluated));
						List<Literal> scouts = new ArrayList<Literal>();
						for(Point scout : ((OriginPoint)p).scouts) {
							Literal s = ASSyntax.createLiteral("scout");
							s.addTerm(new NumberTermImpl(scout.x));
							s.addTerm(new NumberTermImpl(scout.y));
							scouts.add(s);
						}
						List<Literal> retrievers = new ArrayList<Literal>();
						for(Point retriever : ((OriginPoint)p).retrievers) {
							Literal s = ASSyntax.createLiteral("retriever");
							s.addTerm(new NumberTermImpl(retriever.x));
							s.addTerm(new NumberTermImpl(retriever.y));
							retrievers.add(s);
						}
						literal.addTerm(ASSyntax.createList(scouts.toArray(new Literal[scouts.size()])));
						literal.addTerm(ASSyntax.createList(retrievers.toArray(new Literal[retrievers.size()])));
						literal.addTerm(new NumberTermImpl(((OriginPoint)p).maxPosS));
						literal.addTerm(new NumberTermImpl(((OriginPoint)p).maxPosW));
						literal.addTerm(new NumberTermImpl(((OriginPoint)p).maxPosE));
					} else {
						literal = ASSyntax.createLiteral("goal");
					}
					NumberTerm x = new NumberTermImpl(p.x);
					NumberTerm y = new NumberTermImpl(p.y);
					literal.addTerm(x);
					literal.addTerm(y);
					goals.add(literal);
				}
				cluster.addTerm(ASSyntax.createList(goals.toArray(new Literal[goals.size()])));
				things.add(cluster);
			}
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		clusters.set(arraythings);
	}
	
	@OPERATION 
	void getGoals(String name, String cluster, OpFeedbackParam<Literal[]> goals){
		List<Literal> things 		= new ArrayList<Literal>();
		for(Point p : agentmaps.get(name).get(cluster)) {
			Literal literal = null;
			if(p instanceof OriginPoint) {
				literal = ASSyntax.createLiteral("origin");
				literal.addTerm(new Atom(((OriginPoint) p).evaluated));
			} else {
				literal = ASSyntax.createLiteral("goal");
			}
			NumberTerm x = new NumberTermImpl(p.x);
			NumberTerm y = new NumberTermImpl(p.y);
			literal.addTerm(x);
			literal.addTerm(y);
			things.add(literal);
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		goals.set(arraythings);
	}
	
	@OPERATION
	void addAvailableAgent(String name, String type) {
		agentAvailable.put(name, type);
	}
	
	@OPERATION
	void removeAvailableAgent(String name) {
		agentAvailable.remove(name);
	}
	
	@OPERATION 
	void getAvailableAgent(OpFeedbackParam<Literal[]> list){
		List<Literal> agents 		= new ArrayList<Literal>();
		for (Map.Entry<String, String> entry : agentAvailable.entrySet()) {
			Literal literal = ASSyntax.createLiteral("agent");	
			Atom name = new Atom(entry.getKey());
			Atom type = new Atom(entry.getValue());
			literal.addTerm(name);
			literal.addTerm(type);
			agents.add(literal);
		}
		Literal[] arrayagents = agents.toArray(new Literal[agents.size()]);
		list.set(arrayagents);
	}
	
	@OPERATION 
	void getAvailableMeType(String me, OpFeedbackParam<String> type) {
		type.set(agentAvailable.get(me));
	}
	
	@OPERATION
	void getBlocks(OpFeedbackParam<Literal[]> list) {
		List<Literal> things = new ArrayList<Literal>();
		for(Pair<String, String> p : ourBlocks) {
			Literal literal = ASSyntax.createLiteral("block");	
			literal.addTerm(ASSyntax.createAtom(p.getFirst()));
			literal.addTerm(ASSyntax.createAtom(p.getSecond()));
			things.add(literal);
		}
		Literal[] arraythings = things.toArray(new Literal[things.size()]);
		list.set(arraythings);
	}
	
	@OPERATION
	void addBlock(String ag, String b) {
		ourBlocks.add(new Pair<String, String>(ag, b));
	}
	
	@OPERATION
	void removeBlock(String ag) {
		ourBlocks.removeIf(p -> p.getFirst().equals(ag));
	}
	
	@OPERATION
	void clearTeam() {
		agentNames.clear();
		actionsByStep.clear();
		agentmaps.clear();
		agentAvailable.clear();
		map1.clear();
		map2.clear();
		map3.clear();
		map4.clear();
		map5.clear();
		map6.clear();
		map7.clear();
		map8.clear();
		map9.clear();
		map10.clear();
		retrieversAvailablePositions.clear();
		ourBlocks.clear();
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
