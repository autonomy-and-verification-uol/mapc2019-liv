package liv.agentcontest2019;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;


public class ScenarioRunSampleReconnectTeamA {
	
	@Before
	public void setUp() {
		try {			
			JaCaMoLauncher.main(new String[] {"liv-mapc2019.jcm"});
		} catch (JasonException e) {
			System.out.println("Exception: "+e.getMessage());
			e.printStackTrace();
		}
	}
	
	@Test
	public void run() {		
	}
}
