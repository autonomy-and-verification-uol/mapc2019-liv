package env.map;

/**
 * Static class to create cells. All methods names should be self-explanatory
 * @author papacchf
 *
 */
public class CellFactory {
	
	public static Cell getNewEmptyCell() {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		return newCell;
	}
	
	public static Cell getNewUnseenCell() {
		return new Cell();
	}
	
	public static Cell getNewDispenserCell(String dispenserType) {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setDispenser(true);
		newCell.setDispenserType(dispenserType);
		return newCell;
	}
	
	public static Cell getNewWallCell() {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setWall(true);
		return newCell;
	}
	
	public static Cell getNewGoalCell() {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setGoal(true);
		return newCell;
	}
}
