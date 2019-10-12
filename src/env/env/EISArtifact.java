package env;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.*;


import java.awt.Point;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;


import cartago.AgentId;
import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import cartago.ObsProperty;
import cartago.OpFeedbackParam;
import eis.AgentListener;
import eis.EnvironmentListener;
import eis.exceptions.*;
import eis.iilang.*;
import massim.eismassim.EnvironmentInterface;

public class EISArtifact extends Artifact implements AgentListener {

	private Logger logger = Logger.getLogger(EISArtifact.class.getName());

	private Map<String, AgentId> agentIds;
	private Map<String, String> agentToEntity;
	private List<Literal> start = new ArrayList<Literal>();
	private List<Literal> percs = new ArrayList<Literal>();
//	private List<Literal> signalList = new ArrayList<Literal>();
	
	private List<Literal> obstacleList = new ArrayList<Literal>();
	private List<Literal> blockList = new ArrayList<Literal>();
	
	private Point mypos = new Point(0,0);
	
	private EnvironmentInterface ei = null;
	private boolean receiving;
	private int lastStep = -1;
	
	public EISArtifact() {
		agentIds      = new ConcurrentHashMap<String, AgentId>();
		agentToEntity = new ConcurrentHashMap<String, String>();
	}
	
	protected void init(String config) throws IOException, InterruptedException {
		
		
		
		ei = new EnvironmentInterface(config);
        try {
            ei.start();
        } catch (ManagementException e) {
            e.printStackTrace();
        }
        ei.attachEnvironmentListener(new EnvironmentListener() {
            public void handleNewEntity(String entity) {}
            public void handleStateChange(EnvironmentState s) {
                logger.info("new state "+s);
            }
            public void handleDeletedEntity(String arg0, Collection<String> arg1) {}
            public void handleFreeEntity(String arg0, Collection<String> arg1) {}
        });
        
	}
	
	@OPERATION
	void register(String entity)  {
		String agent = getCurrentOpAgentId().getAgentName();
		logger = Logger.getLogger(EISArtifact.class.getName()+"_"+agent);
		logger.info("Registering " + agent + " to entity " + entity);
		try {
			ei.registerAgent(agent);
		} catch (Exception e) {
			e.printStackTrace();
		}
		ei.attachAgentListener(agent, this);
		try {
			ei.associateEntity(agent, entity);
		} catch (Exception e) {
			e.printStackTrace();
		}
		agentToEntity.put(agent, entity);
		agentIds.put(agent, getCurrentOpAgentId());
        if (ei != null) {
	        receiving = true;
			execInternalOp("receiving", agent);
        }
	}
	
	@OPERATION
	void action(String action) throws NoValueException {
		try {
			Literal literal = Literal.parseLiteral(action);
		
			String agent = getCurrentOpAgentId().getAgentName();
			Action a = Translator.literalToAction(literal);
			ei.performAction(agent, a);
//			long endTime = System.nanoTime();
//			long duration = (endTime - startTime) / 1000000;
//			logger.info("Executed action "+a+" step "+lastStep+". Time from percept: "+duration);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	@INTERNAL_OPERATION
	void receiving(String agent) throws JasonException {
		lastStep = -1;
		Collection<Percept> previousPercepts = new ArrayList<Percept>();
		
		//		await_time(1000);
		while(!ei.isEntityConnected(agentToEntity.get(agent)))
			await_time(100);
		
		while (receiving) {
			await_time(100);
			if (ei != null) {
				try {
//					if (ei.getAllPercepts(agent).get(agentToEntity.get(agent))) {
						Collection<Percept> percepts = ei.getAllPercepts(agent).get(agentToEntity.get(agent));
						if (!percepts.isEmpty()) {
//							startTime = System.nanoTime();
//							logger.info("***"+percepts);
		//					if (agent.equals("vehicle1")) { logger.info("***"+percepts); }
							int currentStep = getCurrentStep(percepts);
							if (lastStep != currentStep) { // only updates if it is a new step
								lastStep = currentStep;
								//logger.info("Agent "+agent);
								updatePerception(agent, previousPercepts, percepts);
								previousPercepts = percepts;
							}
						}
//					}
				} catch (PerceiveException | NoEnvironmentException e) {
					e.printStackTrace();
				}
			}
		}
	}

	private int getCurrentStep(Collection<Percept> percepts) throws JasonException  {
		obstacleList.clear();
		blockList.clear();
		int step = -10;
		for (Percept percept : percepts) {
			if (percept.getName().equals("step")) {
				//logger.info(percept+" "+percept.getParameters().getFirst());
				step = new Integer(percept.getParameters().getFirst().toString());
			}
			else if (percept.getName().equals("obstacle")) {
				Literal literal = Translator.perceptToLiteral(percept);
				obstacleList.add(literal); 
			}
			else if (percept.getName().equals("thing") && (percept.getParameters().get(2).toString().equals("block") || percept.getParameters().get(2).toString().equals("entity"))) { 
				Literal literal = Translator.perceptToLiteral(percept);
				if((int)((NumberTerm) literal.getTerm(0)).solve() != 0 || (int)((NumberTerm) literal.getTerm(1)).solve() != 0)
					blockList.add(literal); 
			}
		}
//		logger.info("@@@@ "+obstacleList);
//		logger.info("@@@@ "+blockList);
		return step;
	}
	
	private void updatePerception(String agent, Collection<Percept> previousPercepts, Collection<Percept> percepts) throws JasonException {
		for (Percept old: previousPercepts) {
			if (step_obs_prop.contains(old.getName())) {
				if (!percepts.contains(old) || old.getName().equals("lastAction") || old.getName().equals("lastActionResult") || old.getName().equals("lastActionParams") || old.getName().equals("goal") || old.getName().equals("thing")) { // not perceived anymore
					Literal literal = Translator.perceptToLiteral(old);
					try{				
						removeObsPropertyByTemplate(old.getName(), (Object[]) literal.getTermsArray());
					}
					catch (Exception e) {
						logger.info("error removing old perception "+literal+" "+e.getMessage());
						logger.info("P*** "+percepts);
						logger.info("O*** "+previousPercepts);
					}
//											logger.info("removing old perception "+literal);
				}
			}
		}
		
		// compute new perception
		Literal step 				= null;
		Literal lastAction			= null;
		Literal lastActionResult 	= null;
		Literal lastActionParams	= null;
		Literal actionID 			= null;
		for (Percept percept: percepts) {
			if ( step_obs_prop.contains(percept.getName()) ) {
				if (!previousPercepts.contains(percept) || percept.getName().equals("lastAction") || percept.getName().equals("lastActionResult") || percept.getName().equals("lastActionParams") || percept.getName().equals("goal") || percept.getName().equals("thing")) { // really new perception 
					Literal literal = Translator.perceptToLiteral(percept);
					if (percept.getName().equals("step")) {
						step = literal;
					} else if (percept.getName().equals("simEnd")) {
						defineObsProperty(percept.getName(), (Object[]) literal.getTermsArray());
						cleanObsProps(match_obs_prop);
						lastStep = -1;
						break;
					} else {
						if (percept.getName().equals("lastActionResult")) {
							lastActionResult = literal;
						} 
						else if (percept.getName().equals("lastAction")) { lastAction = literal; }
						else if (percept.getName().equals("lastActionParams")) { lastActionParams = literal; }
						else if (percept.getName().equals("actionID")) { actionID = literal; }
						else {
							percs.add(literal); 
						}
					}
				}
			} if (match_obs_prop.contains(percept.getName())) {
				Literal literal = Translator.perceptToLiteral(percept);
				start.add(literal);
			}
		}
		



		if (!start.isEmpty()) {
			for (Literal lit: start) {
				defineObsProperty(lit.getFunctor(), (Object[]) lit.getTermsArray());
			}
			start.clear();
		}
		if (step != null) {
			if (lastAction.getTerm(0).toString().equals("move") && lastActionResult.getTerm(0).toString().equals("success")) {
				if (lastActionParams.getTerm(0).toString().contains("n")) { mypos.y--; }
				else if (lastActionParams.getTerm(0).toString().contains("s")) { mypos.y++; }
				else if (lastActionParams.getTerm(0).toString().contains("e")) { mypos.x++; }
				else if (lastActionParams.getTerm(0).toString().contains("w")) { mypos.x--; }
			}
//			logger.info("My current position is X = "+mypos.x+" Y = "+mypos.y+" Step "+step);
			defineObsProperty(step.getFunctor(), (Object[]) step.getTermsArray());
			defineObsProperty(lastAction.getFunctor(), (Object[]) lastAction.getTermsArray());
			defineObsProperty(lastActionResult.getFunctor(), (Object[]) lastActionResult.getTermsArray());
			defineObsProperty(lastActionParams.getFunctor(), (Object[]) lastActionParams.getTermsArray());
			
			for (Literal lit: percs) {
				defineObsProperty(lit.getFunctor(), (Object[]) lit.getTermsArray());
			}
			percs.clear();
//			if (!signalList.isEmpty()) {
//				for (Literal lit: signalList) {
//					signal(agentIds.get(agent),lit.getFunctor(),(Object[]) lit.getTermsArray());
//				}
//				signalList.clear();
//			}
			
			defineObsProperty(actionID.getFunctor(), (Object[]) actionID.getTermsArray());
		}
	}
	
	private void cleanObsProps(Set<String> obSet) {
		for (String obs: obSet) {
			cleanObsProp(obs);
		}
	}

	private void cleanObsProp(String obs) {
		ObsProperty ob = getObsProperty(obs);
		while (ob != null) {
//			logger.info("Removing "+ob);
			removeObsProperty(obs);
			ob = getObsProperty(obs);
		}
	}

	@OPERATION
	void stopReceiving() {
		receiving = false;
	}
	
	@OPERATION 
	void getMyPos(OpFeedbackParam<Integer> x, OpFeedbackParam<Integer> y){
		x.set(mypos.x);
		y.set(mypos.y);
	}
	
	@OPERATION 
	void updateMyPos(int originx, int originy){
		mypos.x = mypos.x + originx;
		mypos.y = mypos.y + originy;
	}

	@OPERATION 
	void resetMyPos(){
		mypos.x = 0;
		mypos.y = 0;
	}
	
	static Set<String> match_obs_prop = new HashSet<String>( Arrays.asList(new String[] {
		"name",
		"steps",
		"team",
		"vision",
	}));
	
	static Set<String> step_obs_prop = new HashSet<String>( Arrays.asList(new String[] {
		"actionID",
		"step",
		"simEnd",
		"lastAction",
		"lastActionResult",
		"score",
		"thing",
		"task",
		"obstacle",
		"goal",
		"attached",
		"lastActionParams",
		"energy",
		"disabled",
//		"timestamp",
//		"deadline",
	}));
	
    @Override
    public void handlePercept(String agent, Percept percept) {}
    
    //Planner related methods
    // all coordinates are assumed to be visible to the agent
    private Literal[] convertToAgentPlan(List<String> returnedPlan) {
    	
    	if(returnedPlan == null) 
    		return new Literal[0];
    	
//    	logger.info(returnedPlan + "");
    	
    	List<Literal> actions = new ArrayList<Literal>();
    	
    	for(String action : returnedPlan) {
    		int par = action.indexOf("(");
    		String functor = action.substring(0, par);
//    		logger.info(functor + "(");
    		List<Term> args = new ArrayList<>();
    		for(String arg : action.substring(par + 1, action.length() - 1).split(",")) {
//    			logger.info(arg);
    			args.add(ASSyntax.createAtom(arg));
    		}
//    		logger.info(")");
    		actions.add(ASSyntax.createLiteral(functor, args.toArray(new Term[args.size()])));
    	}
    	
    	return actions.toArray(new Literal[actions.size()]);
    }
    
    // NOTE: clear is supposed to be true if the clear action is allowed, false otherwise.
    @OPERATION
    public void getPlanAgentToGoal(String agent, int goalX, int goalY, OpFeedbackParam<Literal[]> plan, int clear) {
    	String goalCell = coordinate2String(goalX) + coordinate2String(goalY);
    	String goalStatement = createGoalStatement("(at a " + goalCell + ")");
//    	logger.info("Goal statement: " + goalStatement);
    	LinkedList<String> returnedPlan = getPlan(agent, goalStatement, null, 0, clear);
    	plan.set(convertToAgentPlan(returnedPlan));
    }
    
    @OPERATION
    public void getPlanAgentToGoal(String agent, int goalX, int goalY, int blockX, int blockY, OpFeedbackParam<Literal[]> plan, int clear) {
    	String goalCell = coordinate2String(goalX) + coordinate2String(goalY);
    	String attachedBlockCell = coordinate2String(blockX) + coordinate2String(blockY);
    	String goalStatement = createGoalStatement("(at a " + goalCell + ")");
//    	logger.info("Goal statement: " + goalStatement);
    	LinkedList<String> returnedPlan = getPlan(agent, goalStatement, attachedBlockCell, 1, clear);
    	plan.set(convertToAgentPlan(returnedPlan));
    }
    
    @OPERATION
    public void getPlanBlockToGoal(String agent, int goalX, int goalY, int blockX, int blockY, OpFeedbackParam<Literal[]> plan, int clear) {
    	String goalCell = coordinate2String(goalX) + coordinate2String(goalY);
    	String attachedBlockCell = coordinate2String(blockX) + coordinate2String(blockY);
    	String goalStatement = createGoalStatement("(at b0 " + goalCell + ")");
//    	logger.info("Goal statement: " + goalStatement);
    	LinkedList<String> returnedPlan = getPlan(agent, goalStatement, attachedBlockCell, 1, clear);
    	plan.set(convertToAgentPlan(returnedPlan));
    }
    
    private String createGoalStatement(String actualGoal) {
    	return "\t(:goal " + actualGoal + ")";
    }
    
    private LinkedList<String> getPlan(String agent, String goalStatement, String attachedBlockCoordinates, int blockCounter, int clear) {
    	
    	LinkedList<String> plan = null;
    	
    	if(new File("./planner/" + agent + "_problem.pddl").delete())
    		logger.info("DELETED " + agent +"_problem.pddl");
    	if(new File("./planner/" + agent).delete())
    		logger.info("DELETED " + agent);
    	
    	try {
    	
//	    	logger.info("We are in the getPlan method!");
	    	
	    	Set<String> nonEmptyCells = new HashSet<String>();
	    	
	    	nonEmptyCells.add("p0p0");
	    	
	    	String problemFileName = agent + "_problem.pddl";
	    	
	    	File problemFile = new File("planner/" + problemFileName);
	    	
	    	FileWriter problemFileWriter = new FileWriter(problemFile);
	    	
	    	String outputFileName = agent + "_output";
	    	
	    	String preamble = "(define (problem " + agent + ")\n"
	    			+ "\t(:domain mapc)\n";
	    	
	    	problemFileWriter.write(preamble);
	    	
	    	List<String> blocks = new LinkedList<String>();
	    	List<String> obstacles = new LinkedList<String>();
	    	
	    	List<String> initBlocksObstacles = new LinkedList<String>();
	    	
	    	int obstaclesNumber = 0;
	    	int blocksNumber = blockCounter;
	    	
	    	//Analysing blocks list
	    	for(Literal l : this.blockList) {
	    		int x = (int)((NumberTerm) l.getTerm(0)).solve();
	    		int y = (int)((NumberTerm) l.getTerm(1)).solve();
	    		String cell = coordinate2String(x) + coordinate2String(y);
	    		String blockID = null;
	    		if(cell.equals(attachedBlockCoordinates))
	    			blockID = "b0";
				else {
					blockID = "b" + blocksNumber;
					blocksNumber++;
				}
	    		nonEmptyCells.add(cell);
	    		blocks.add(blockID);
	    		initBlocksObstacles.add("(at " + blockID + " " + cell + ")");
	    	}
	    	
	    	//Analysing obstacles list
	    	for(Literal l : this.obstacleList) {
	    		int x = (int)((NumberTerm) l.getTerm(0)).solve();
	    		int y = (int)((NumberTerm) l.getTerm(1)).solve();
	    		String cell = coordinate2String(x) + coordinate2String(y);
	    		String obstaclesID = "o" + obstaclesNumber;
	    		obstaclesNumber++;
	    		nonEmptyCells.add(cell);
	    		obstacles.add(obstaclesID);
	    		initBlocksObstacles.add("(at " + obstaclesID + " " + cell + ")");
	    	}
	    	
	    	//Creating the :objects field
	    	String objects = "\t(:objects\n";
	    	
	    	String blocksDeclaration = "\t\t";
	    	
	    	for(String b : blocks)
	    		blocksDeclaration += b + " ";
	    	
	    	if(!blocksDeclaration.equals("\t\t"))
	    		objects += blocksDeclaration + "- block\n";
	    	
	    	String obstaclesDeclaration = "\t\t";
	    	
	    	for(String o : obstacles)
	    		obstaclesDeclaration += o + " ";
	    	
	    	if(!obstaclesDeclaration.equals("\t\t"))
	    		objects += obstaclesDeclaration + "- obstacle\n";
	    	
	    	objects += "\t)\n";
	    	
	    	// writing objects to file
	    	if(!this.obstacleList.isEmpty() || !this.blockList.isEmpty())
	    		problemFileWriter.write(objects.toString());
	    	
	    	// writing :init field
	    	problemFileWriter.write("\t(:init\n");
	    	problemFileWriter.write("\t\t(rotation cw n e)\n");
	    	problemFileWriter.write("\t\t(rotation cw e s)\n");
	    	problemFileWriter.write("\t\t(rotation cw s w)\n");
	    	problemFileWriter.write("\t\t(rotation cw w n)\n");
	    	problemFileWriter.write("\t\t(rotation ccw n w)\n");
	    	problemFileWriter.write("\t\t(rotation ccw w s)\n");
	    	problemFileWriter.write("\t\t(rotation ccw s e)\n");
	    	problemFileWriter.write("\t\t(rotation ccw e n)\n");
	    	problemFileWriter.write("\t\t(at a p0p0)\n");
	    	problemFileWriter.write("\t\t(= (total-cost) 0)\n");
	    	
	    	if(attachedBlockCoordinates == null)
	    		problemFileWriter.write("\t\t(alone a)\n");
	    	else
	    		problemFileWriter.write("\t\t(attached a b0)\n");
	    	
	    	for(int i = -5; i < 6; i++) {
	    		int init_j = 5 - Math.abs(i);
	    		for(int j = -init_j; j < init_j + 1; j++) {
	    			String cellName = coordinate2String(j) + coordinate2String(i);
	    			if(!nonEmptyCells.contains(cellName))
	    				problemFileWriter.write("\t\t(empty " + cellName + ")\n");
	    			
	    			if(	Math.abs(j) + Math.abs(i - 1) < 6 )
	    				problemFileWriter.write("\t\t(adjacent n " + cellName + " " + coordinate2String(j) + coordinate2String(i - 1) + ")\n");
	    			
	    			if(	Math.abs(j + 1) + Math.abs(i) < 6 )
	    				problemFileWriter.write("\t\t(adjacent e " + cellName + " " + coordinate2String(j + 1) + coordinate2String(i) + ")\n");
	    			
	    			if(	Math.abs(j) + Math.abs(i + 1) < 6 )
	    				problemFileWriter.write("\t\t(adjacent s " + cellName + " " + coordinate2String(j) + coordinate2String(i + 1) + ")\n");
	    			
	    			if(	Math.abs(j - 1) + Math.abs(i) < 6 )
	    				problemFileWriter.write("\t\t(adjacent w " + cellName + " " + coordinate2String(j - 1) + coordinate2String(i) + ")\n");
	    		}
	    	}
	    	
	    	for(String otherInit : initBlocksObstacles)
	    		problemFileWriter.write("\t\t" + otherInit + "\n");
	    	problemFileWriter.write("\t)\n");
	    	
	    	// writing goal
	    	problemFileWriter.write(goalStatement + "\n");
	    	
	    	//metric + end bracket
	    	problemFileWriter.write("\t(:metric minimize (total-cost))\n)");
	    	
	    	problemFileWriter.flush();
	    	problemFileWriter.close();
	    	
	    	plan = callPlanner2(agent, clear);

    	} catch (Exception e) {
    		logger.info("Exception while invoking the planner, here is the returned error message:");
    		logger.info(e.getMessage());
    		plan = null;
    	}
    	
    	return plan; 
    }
    
    private LinkedList<String> callPlanner(String agentName, int clear) throws IOException, InterruptedException {
    	String problem = agentName + "_problem.pddl";
    	String output = agentName + "_output";
//    	logger.info("problem file name: " + problem);
//       	logger.info("output file name: " + output);
       	
       	ProcessBuilder pb = null;
       	
       	if(clear == 1)
       	   	pb = new ProcessBuilder("./run.sh", "domain_clear.pddl", agentName);
       	else
       		pb = new ProcessBuilder("./run.sh", "domain.pddl", agentName);
       	
    	pb.directory(new File("./planner"));
		Process p = pb.start();
		p.waitFor();
		
		File planResult = new File("./planner/" + agentName);
		
		if(!planResult.exists()) {
			logger.info("NO PLAN returned or problems with the planner invocation");
			return null;
		}
		
		
		Scanner s = new Scanner(planResult);
		LinkedList<String> plan = new LinkedList<String>();
		
		while(s.hasNextLine()) {
			String line = s.nextLine();
			plan.add(line);
		}
		
		s.close();
		
//	   	logger.info("We have a plan!");
	   	
		return plan;
    }
    
    private LinkedList<String> callPlanner2(String agentName, int clear) throws IOException, InterruptedException {
    	String problem = agentName + "_problem.pddl";
    	String output = agentName + "_output";
//    	logger.info("problem file name: " + problem);
//       	logger.info("output file name: " + output);
       	
       	ProcessBuilder pb = null;
       	
       	if(clear == 1)
       	   	pb = new ProcessBuilder("./run2.sh", "domain_clear.pddl", agentName);
       	else
       		pb = new ProcessBuilder("./run2.sh", "domain.pddl", agentName);
       	
    	pb.directory(new File("./planner"));
		Process p = pb.start();
		p.waitFor();
		
		Scanner s = new Scanner(p.getInputStream());
		
		LinkedList<String> plan = new LinkedList<String>();
		
		while(s.hasNextLine()) {
			String line = s.nextLine();
			if(line.equals("NO PLAN")) {
				s.close();
				return null;
			}
			plan.add(line);
		}
		
		s.close();
		
//	   	logger.info("We have a plan!");
	   	
		return plan;
    }
    
    private String coordinate2String(int coordinate) {
    	if(coordinate < 0)
    		return "n" + Math.abs(coordinate);
    	return "p" + coordinate;
    }
}