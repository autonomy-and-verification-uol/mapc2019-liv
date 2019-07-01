package env;

import java.util.logging.Logger;

import cartago.Artifact;

public class MapArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(MapArtifact.class.getName());

	void init(){
		logger = Logger.getLogger(""+getId());
		logger.info("Map Artifact "+getId()+" has been created!");
	}
		
}
