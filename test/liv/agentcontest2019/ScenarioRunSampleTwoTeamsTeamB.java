package liv.agentcontest2019;

import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;


public class ScenarioRunSampleTwoTeamsTeamB {
	
	@Before
	public void setUp() {
		try {			
			JaCaMoLauncher.main(new String[] {"liv-mapc2019TeamB.jcm"});
		} catch (JasonException e) {
			System.out.println("Exception: "+e.getMessage());
			e.printStackTrace();
		}
	}
	
	@Test
	public void run() {		
	}
}







