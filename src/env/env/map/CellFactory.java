package env.map;

/**
 * Static class to create cells. All methods names should be self-explanatory
 * @author papacchf
 *
 */
public class CellFactory {
	
	public static Cell getNewEmptyCell(int step) {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setStep(step);
		return newCell;
	}
	
	public static Cell getNewUnseenCell(int step) {
		Cell newCell = new Cell();
		newCell.setStep(step);
		return newCell;
	}
	
	public static Cell getNewDispenserCell(String dispenserType, int step) {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setDispenser(true);
		newCell.setDispenserType(dispenserType);
		newCell.setStep(step);
		return newCell;
	}
	
	public static Cell getNewWallCell(int step) {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setWall(true);
		newCell.setStep(step);
		return newCell;
	}
	
	public static Cell getNewGoalCell(int step) {
		Cell newCell = new Cell();
		newCell.setSeen(true);
		newCell.setGoal(true);
		newCell.setStep(step);
		return newCell;
	}
}
