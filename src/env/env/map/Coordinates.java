package env.map;

/**
 * Simple class representing a pair of integers
 * @author papacchf
 *
 */
public class Coordinates {
	private int xCoordinate;
	private int yCoordinate;
	
	public Coordinates() {
		this.xCoordinate = 0;
		this.yCoordinate = 0;
	}
	
	public Coordinates(int x, int y) {
		this.xCoordinate = x;
		this.yCoordinate = y;
	}

	//getters and setters
	public int getXCoordinate() {
		return xCoordinate;
	}

	public void setXCoordinate(int xCoordinate) {
		this.xCoordinate = xCoordinate;
	}

	public int getYCoordinate() {
		return yCoordinate;
	}

	public void setYCoordinate(int yCoordinate) {
		this.yCoordinate = yCoordinate;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + xCoordinate;
		result = prime * result + yCoordinate;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Coordinates other = (Coordinates) obj;
		if (xCoordinate != other.xCoordinate)
			return false;
		if (yCoordinate != other.yCoordinate)
			return false;
		return true;
	}
	
	@Override
	public String toString() {
		return "(" + this.xCoordinate + ", " + this.yCoordinate + ")";
	}
}
