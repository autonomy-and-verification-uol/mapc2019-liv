package env.map;

public class Tests {

	public static void main(String[] args) {
		//Simple map for agent1
		OurMap map1 = new OurMap("A1");
		
		map1.init();
		
		map1.updateCell(CellFactory.getNewGoalCell(), new Coordinates(-2, 3));
		map1.updateCell(CellFactory.getNewDispenserCell("d1"), new Coordinates(2, -3));
		map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(-2, -3));		
		
		map1.printMap();

		//Same map for agent2
		OurMap map2 = new OurMap("A2");
		
		map2.init();
		
		map2.updateCell(CellFactory.getNewGoalCell(), new Coordinates(-2, 3));
		map2.updateCell(CellFactory.getNewDispenserCell("d3"), new Coordinates(2, -3));
		map2.updateCell(CellFactory.getNewWallCell(), new Coordinates(-2, -3));		
		
		map2.printMap();
		
		//Merging the maps with map1 being the one with added information and printing the result
		map1.mergeMaps("A1", new Coordinates(-7, 2), map2, "A2");
		
		map1.printMap();		
	}

}
