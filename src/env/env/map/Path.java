package env.map;

import java.util.LinkedList;
import java.util.List;

public class Path implements Comparable<Path>{
	private LinkedList<Coordinates> path;
	private Coordinates terminalNode;
	private int heuristicValue;
	
	public Path() {
		this.path = null;
		this.terminalNode = null;
		this.heuristicValue = -1;
	}
	
	public Path(Coordinates cell, int heuristic) {
		this.path = new LinkedList<Coordinates>();
		this.path.add(cell);
		this.terminalNode = cell;
		this.heuristicValue = heuristic;
	}
		
	
	public LinkedList<Coordinates> getPath() {
		return path;
	}


	public Coordinates getTerminalNode() {
		return terminalNode;
	}

	public void setTerminalNode(Coordinates terminalNode) {
		this.terminalNode = terminalNode;
	}

	public int getHeuristicValue() {
		return heuristicValue;
	}

	public void setHeuristicValue(int heuristicValue) {
		this.heuristicValue = heuristicValue;
	}
	
	public int getLength() {
		return this.path.size() - 1;
	}

	//Probably not the best place for the method...
	//It returns a new path that is an extension of the current path
	public Path addSuccessor(Coordinates cell, int heuristic) {
		Path newPath = new Path();
		newPath.path = new LinkedList<Coordinates>(this.path);
		newPath.getPath().add(cell);
		newPath.setHeuristicValue(heuristic);
		newPath.setTerminalNode(cell);
		return newPath;
	}

	//Assumption: the two coordinates are adjacent
	private String getDirection(Coordinates c1, Coordinates c2) {
		if(c1.getXCoordinate() < c2.getXCoordinate())
			return "e";
		
		if(c1.getXCoordinate() > c2.getXCoordinate())
			return "w";
		
		if(c1.getYCoordinate() < c2.getYCoordinate())
			return "s";
		
		return "n";
	}
	
	public List<String> path2directions(){
		List<String> directions = new LinkedList<String>();
		for(int i = 0; i < this.getLength(); i++)
			directions.add(this.getDirection(this.path.get(i), this.path.get(i + 1)));
		return directions;
	}
	
	public void print() {
		for(int i = 0; i < this.path.size() - 1; i++)
			System.out.print(this.path.get(i).toString() + " -> ");
		System.out.println(this.path.get(this.path.size() - 1).toString());
	}
	
	@Override
	public int compareTo(Path p) {
		return this.heuristicValue - p.getHeuristicValue();
	}
}
