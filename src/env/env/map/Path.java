package env.map;

import java.util.LinkedList;

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
