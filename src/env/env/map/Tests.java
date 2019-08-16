package env.map;

public class Tests {

	public static void main(String[] args) throws Exception {
		//Simple map for agent1
		OurMap map1 = new OurMap("A1");
		
		map1.init();
		
		for(int i = -7; i < 8; i++)
			for(int j = -7; j < 8; j++)
				map1.updateCell(CellFactory.getNewEmptyCell(), new Coordinates(i, j));
		
		for(int i = -7; i < -3; i++)
			map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(4, i));
		
		for(int i = 4; i < 8; i++)
			map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(-4, i));
		
		
		for(int i = -2; i <= 0; i++) {
			int maxY = 2 - Math.abs(i);
			for(int j = -maxY; j <= maxY; j++ )
				map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(i, j));
		}
		
		for(int i = 1; i <= 2; i++) {
			int maxY = 2 - Math.abs(i);
			for(int j = -maxY; j <= maxY; j++ )
				map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(i, j));
		}
		
		for(int i = 4; i < 8; i++)
			map1.updateCell(CellFactory.getNewUnseenCell(), new Coordinates(i, 0));
		//map1.updateCell(CellFactory.getNewGoalCell(), new Coordinates(-2, 3));
		//map1.updateCell(CellFactory.getNewDispenserCell("d1"), new Coordinates(2, -3));
		//map1.updateCell(CellFactory.getNewWallCell(), new Coordinates(-2, -3));		
		
		map1.printMap();
		
		Path p = map1.search(new Coordinates(-6, 6), new Coordinates(6, -6));
	
		p.print();

		//Same map for agent2
		/*
		OurMap map2 = new OurMap("A2");
		
		map2.init();
		
		map2.updateCell(CellFactory.getNewGoalCell(), new Coordinates(-2, 3));
		map2.updateCell(CellFactory.getNewDispenserCell("d3"), new Coordinates(2, -3));
		map2.updateCell(CellFactory.getNewWallCell(), new Coordinates(-2, -3));		
		
		map2.printMap();
		
		//Merging the maps with map1 being the one with added information and printing the result
		map1.mergeMaps("A1", new Coordinates(-7, 2), map2, "A2");
		
		map1.printMap();
		*/		
	}

}
