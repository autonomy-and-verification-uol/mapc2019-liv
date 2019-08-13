package env.map;

/**
 * Simple class representing a cell + getters/setters and print methods
 * @author papacchf
 *
 */
public class Cell {
	private boolean seen; 
	private boolean dispenser;
	private String dispenserType;
	private boolean wall;
	private boolean goal;
	
	public Cell() {
		this.seen = false;
		this.dispenser = false;
		this.dispenserType = null;
		this.wall = false;
		this.goal = false;
	}

	//getters and setters
	public boolean isSeen() {
		return seen;
	}

	public void setSeen(boolean seen) {
		this.seen = seen;
	}

	public boolean isDispenser() {
		return dispenser;
	}

	public void setDispenser(boolean dispenser) {
		this.dispenser = dispenser;
	}

	public String getDispenserType() {
		return dispenserType;
	}

	public void setDispenserType(String dispenserType) {
		this.dispenserType = dispenserType;
	}

	public boolean isWall() {
		return wall;
	}

	public void setWall(boolean wall) {
		this.wall = wall;
	}
	
	public boolean isGoal() {
		return goal;
	}

	public void setGoal(boolean goal) {
		this.goal = goal;
	}
	
	public void print() {
		System.out.print(this.toString());
	}
	
	public String toString() {
		if(this.dispenser)
			return this.dispenserType;
		else if(!this.seen)
			return "U ";
		else if(this.wall)
			return "W ";
		else if(this.goal)
			return "G ";
		else
			return "E ";
	}
}
