package liv.agentcontest2019;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jade.util.leap.ArrayList;
import jade.util.leap.List;
import jason.JasonException;
import massim.Server;


public class ScenarioRunTest {
	

	@Before
	public void cleanUpFolders() throws IOException {

		File currentDir = new File("");
		String path = currentDir.getAbsolutePath();	
				
		ScenarioRunTest deletefiles = new ScenarioRunTest();
		deletefiles.delete(5, path + "\\logs");
		deletefiles.delete(5, path + "\\log");
		deletefiles.delete(5, path + "\\replays");	
		
	}
	
	public void delete(long nFiles, String directoryFolder) throws IOException {
		
		File currentDir = new File("");
		String path = currentDir.getAbsolutePath();	
		
		File folder = new File(directoryFolder);
		
		if(folder.exists()) {
			File[] listFiles = folder.listFiles();
			String[] filesInDir = folder.list();			
			for ( int i=0; i < listFiles.length - nFiles ; i++ ){
				listFiles[i].delete();
				FileUtils.deleteDirectory(listFiles[i]);				
			}		
		}
		
	}		
	
	@Before
	public void setUp() {

		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					
					Server.main(new String[] {"-conf", "conf/TestConfig.json", "--monitor"});				
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();

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







