package env;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.*;


import java.awt.Point;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
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
	private List<Literal> signalList = new ArrayList<Literal>();
	
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

	private int getCurrentStep(Collection<Percept> percepts) {
		for (Percept percept : percepts) {
			if (percept.getName().equals("step")) {
				//logger.info(percept+" "+percept.getParameters().getFirst());
				return new Integer(percept.getParameters().getFirst().toString());
			}
		}
		return -10;
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
					//						logger.info("removing old perception "+literal);
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
						else { percs.add(literal); }
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
				else { mypos.x--; }
//				logger.info("My current position is X = "+mypos.x+" Y = "+mypos.y);
			}
			defineObsProperty(step.getFunctor(), (Object[]) step.getTermsArray());
			defineObsProperty(lastAction.getFunctor(), (Object[]) lastAction.getTermsArray());
			defineObsProperty(lastActionResult.getFunctor(), (Object[]) lastActionResult.getTermsArray());
			defineObsProperty(lastActionParams.getFunctor(), (Object[]) lastActionParams.getTermsArray());
			
			for (Literal lit: percs) {
				defineObsProperty(lit.getFunctor(), (Object[]) lit.getTermsArray());
			}
			percs.clear();
			if (!signalList.isEmpty()) {
				for (Literal lit: signalList) {
					signal(agentIds.get(agent),lit.getFunctor(),(Object[]) lit.getTermsArray());
				}
				signalList.clear();
			}
			
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
	void updateMyPos(int x, int y){
		mypos.x = x;
		mypos.y = y;
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
   
}