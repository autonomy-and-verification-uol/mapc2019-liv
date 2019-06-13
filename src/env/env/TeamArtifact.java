package env;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;


public class TeamArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(TeamArtifact.class.getName());

	private static Map<String, String>  agentNames 	 	= new HashMap<String, String>();
	private static Map<String, String>  agentRoles 	 	= new HashMap<String, String>();

	private static Map<Integer, Set<String>> actionsByStep   = new HashMap<Integer, Set<String>>();

	
	void init(){
		logger.info("Team Artifact has been created!");
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
