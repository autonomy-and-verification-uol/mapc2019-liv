package env;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.*;
import jason.asSyntax.parser.ParseException;

import static org.junit.Assert.fail;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.logging.Logger;

import massim.scenario.city.data.Location;
import cartago.AgentId;
import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import cartago.ObsProperty;
import eis.EnvironmentInterfaceStandard;
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
	private int mapSet = 0;
	private int ready = 0;
	
	private static Set<String> agents = new ConcurrentSkipListSet<String>();

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
	
	public static Set<String> getRegisteredAgents(){
		return agents;
	}
	
	@OPERATION
	void register(String entity)  {
		String agent = getCurrentOpAgentId().getAgentName();
		logger = Logger.getLogger(EISArtifact.class.getName()+"_"+agent);
		logger.info("Registering " + agent + " to entity " + entity);
		agents.add(agent);
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
	
	@OPERATION
	void initMap(String map, double cellsize, int proximity){
		MapHelper.getInstance().init(map, cellsize, proximity);
		mapSet = 1;
	}
	
	@OPERATION
	void setMap(){
		mapSet = 1;
	}
	
	@OPERATION
	void resetMap(){
		mapSet = 0;
	}
	
	@OPERATION
	void setReady(){
		ready = 1;
	}
	
	@OPERATION
	void unsetReady(){
		ready = 0;
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
						while (ready == 0) { await_time(100); }
						if (!percepts.isEmpty()) {
//							startTime = System.nanoTime();
//							logger.info("***"+percepts);
		//					if (agent.equals("vehicle1")) { logger.info("***"+percepts); }
							int currentStep = getCurrentStep(percepts);
							if (lastStep != currentStep) { // only updates if it is a new step
								lastStep = currentStep;
								if (mapSet == 1) { filterLocations(agent, percepts); }
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
				if (!percepts.contains(old) || old.getName().equals("lastAction") || old.getName().equals("lastActionResult")) { // not perceived anymore
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
//		Literal auction 			= null;
		List<Literal> auction 		= new ArrayList<Literal>();
		Literal lastAction			= null;
		Literal lastActionResult 	= null;
		Literal actionID 			= null;
		for (Percept percept: percepts) {
			if ( step_obs_prop.contains(percept.getName()) ) {
				if (!previousPercepts.contains(percept) || percept.getName().equals("lastAction") || percept.getName().equals("lastActionResult")) { // really new perception 
					Literal literal = Translator.perceptToLiteral(percept);
					if (percept.getName().equals("step")) {
						step = literal;
					} else if(percept.getName().equals("auction")){
						auction.add(literal);
					} else if (percept.getName().equals("simEnd")) {
						defineObsProperty(percept.getName(), (Object[]) literal.getTermsArray());
						cleanObsProps(match_obs_prop);
						lastStep = -1;						
						break;
					} else {
//							logger.info("adding "+literal);
						if (percept.getName().equals("lastActionResult")) {
							lastActionResult = literal;
						} 
						else if (percept.getName().equals("lastAction")) { lastAction = literal; }
//						else if (agent.equals("vehicle1") && (percept.getName().equals("job") || percept.getName().equals("mission"))) { signalList.add(literal); }
						else if (percept.getName().equals("actionID")) { actionID = literal; }
						else if (percept.getName().equals("shop") || percept.getName().equals("workshop") || percept.getName().equals("routeLength") || percept.getName().equals("facility")) { percs.add(0,literal); }
						else { percs.add(literal); }
					}
				}
			} if (match_obs_prop.contains(percept.getName())) {
				Literal literal = Translator.perceptToLiteral(percept);
//					logger.info("adding "+literal);
				if (percept.getName().equals("role")) {
					start.add(0,literal);
				} else { start.add(literal); }
			}
		}

		if (!start.isEmpty()) {
			for (Literal lit: start) {
				defineObsProperty(lit.getFunctor(), (Object[]) lit.getTermsArray());
			}
			start.clear();
		}
			
		if (step != null) {
			for (Literal a : auction) {
				defineObsProperty(a.getFunctor(), (Object[]) a.getTermsArray());
			}
			defineObsProperty(step.getFunctor(), (Object[]) step.getTermsArray());
			defineObsProperty(lastAction.getFunctor(), (Object[]) lastAction.getTermsArray());
			defineObsProperty(lastActionResult.getFunctor(), (Object[]) lastActionResult.getTermsArray());
			
			for (Literal lit: percs) {
				defineObsProperty(lit.getFunctor(), (Object[]) lit.getTermsArray());
			}
			percs.clear();
//			if (!signalList.isEmpty() && acceptJobs == 1) {
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

	static Set<String> match_obs_prop = new HashSet<String>( Arrays.asList(new String[] {
		"map",
		"name",
		"steps",
		"item",
		"upgrade",
		"wellType",
		"role",
		"cellSize",
		"proximity",
		"seedCapital",
		"minLon",
		"maxLon",
		"minLat",
		"maxLat",
		"team",
//		"id",
	}));
	
	static Set<String> step_obs_prop = new HashSet<String>( Arrays.asList(new String[] {
		"chargingStation",
		"actionID",
		"routeLength",
		"shop",			
		"storage",
		"workshop",
		"resourceNode",		
		"dump",
		"lat",
		"lon",
		"charge",
		"load",
		"facility",
		"hasItem",
		"step",
		"simEnd",
		"lastAction",
		"lastActionResult",
		"massium",
		"well",
		"speed",
		"maxLoad",
		"maxBattery",
		"skill",
		"vision",
		"auction",
		"mission",
		"job",
//		"entity",
//		"lastActionParams",
//		"timestamp",
//		"deadline",
//		"route",
	}));
	
	static List<String> location_perceptions = Arrays.asList(new String[] { "shop", "storage", "workshop", "chargingStation", "dump", "entity", "resourceNode", "well" });

	private void filterLocations(String agent, Collection<Percept> perceptions) {
		double agLat = Double.NaN, agLon = Double.NaN;
		for (Percept perception : perceptions) {
			if(perception.getName().equals("lon")){
				agLon = Double.parseDouble(perception.getParameters().get(0).toString());
			}
			if(perception.getName().equals("lat")){
				agLat = Double.parseDouble(perception.getParameters().get(0).toString());
			}
			if (location_perceptions.contains(perception.getName())) {
				boolean isEntity = perception.getName().equals("entity"); // Second parameter of entity is the team. :(
				LinkedList<Parameter> parameters = perception.getParameters();
				String facility = parameters.get(0).toString();
				if (!MapHelper.getInstance().hasLocation(facility)) {
					String local = parameters.get(0).toString();
					double lat = Double.parseDouble(parameters.get(isEntity ? 2 : 1).toString());
					double lon = Double.parseDouble(parameters.get(isEntity ? 3 : 2).toString());
					MapHelper.getInstance().addLocation(local, new Location(lon, lat));
				}
			}
		}
		if(!Double.isNaN(agLat) && !Double.isNaN(agLon)){
			MapHelper.getInstance().addLocation(agent, new Location(agLon, agLat));
		}
	}

    @Override
    public void handlePercept(String agent, Percept percept) {}
   
}