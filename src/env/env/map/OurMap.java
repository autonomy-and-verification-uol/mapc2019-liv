package env.map;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;

/**
 * Class representing a map
 * @author papacchf
 *
 */
public class OurMap {
	private Set<String> knownAgents;
	private Map<String,Coordinates> agents2coordinates;
	private Set<String> knownDispenserTypes;
	private Map<String,Set<Coordinates>> dispenserType2coordinate;
	private Set<Coordinates> knownGoalPositions;
	private Axis<Axis<Cell>> map;
	
	//creates a map with a single cell, representing the origin, and assumes the agent is in that cell
	public OurMap(String agentName) {
		this.knownAgents = new HashSet<String>();
		this.knownAgents.add(agentName);
		this.agents2coordinates = new HashMap<String, Coordinates>();
		Coordinates startingCoordinate = new Coordinates();
		this.agents2coordinates.put(agentName, startingCoordinate);
		this.knownDispenserTypes = new HashSet<String>();
		this.dispenserType2coordinate = new HashMap<String, Set<Coordinates>>();
		this.knownGoalPositions = new HashSet<Coordinates>();
		Axis<Cell> yAxis = new Axis<Cell>(CellFactory.getNewEmptyCell());
		this.map = new Axis<Axis<Cell>>(yAxis);
	}
	
	//Initialise the map with all visible cells as empty
	public void init() {
		
		//To populate the initial map it is enough to call the updateCell method
		//for each one of the 61 cells perceived by the agent at the very beginning
		
		//What follows is an example of how to visit all the 61 cells
		//by first checking all the position on the left (including also the position with x = 0)
		//and then checking those on the right
		
		for(int i = -5; i <= 0; i++) {
			int maxY = 5 - Math.abs(i);
			for(int j = -maxY; j <= maxY; j++ )
				this.updateCell(CellFactory.getNewEmptyCell(), new Coordinates(i, j));
		}
		
		for(int i = 1; i <= 5; i++) {
			int maxY = 5 - Math.abs(i);
			for(int j = -maxY; j <= maxY; j++ )
				this.updateCell(CellFactory.getNewEmptyCell(), new Coordinates(i, j));
		}
	}
	
	//return the coordinates of a specific agent. Returns null if the agent is not known
	public Coordinates getAgentCoordinates(String agent) {
		if(this.knownAgents.contains(agent))
			return this.agents2coordinates.get(agent);
		return null;
	}
	
	//Returns the set of known agents
	public Set<String> getAgents(){
		return this.knownAgents;
	}
	
	//Returns the map
	public Axis<Axis<Cell>> getMap(){
		return this.map;
	}
	
	//Add an agent to the list of known agents and updates its coordinate (adds them if it wasn't there before)
	public void updateAgentCoordinates(String agent, Coordinates coordinates) {
		this.knownAgents.add(agent);
		this.agents2coordinates.put(agent, coordinates);
	}
	
	//Method used to add cells of some default value either to the head or to the tail of an axis
	private <T> void add(T defaultValue, Axis<T> axis, boolean head) {
		if(head) 
			axis.addFirst(defaultValue);
		else
			axis.addLast(defaultValue);
	}
	
	//Updates information on dispenser and/or goals
	private void updateMapInformation(Cell cell, Coordinates coordinates) {
		if(cell.isDispenser()) {
			this.knownDispenserTypes.add(cell.getDispenserType());
			Set<Coordinates> set = this.dispenserType2coordinate.get(cell.getDispenserType());
			if(set == null) {
				set = new HashSet<Coordinates>();
				this.dispenserType2coordinate.put(cell.getDispenserType(), set);
			}
			set.add(coordinates);
		}
		
		if(cell.isGoal())
			this.knownGoalPositions.add(coordinates);
	}
	
	//Add/update a cell in the map
	public void updateCell(Cell cell, Coordinates coordinates) {
		//absolute value of the coordinates
		int moduloX = Math.abs(coordinates.getXCoordinate());
		int moduloY = Math.abs(coordinates.getYCoordinate());
		
		//Adds unseen cells to the head of the x axis if the coordinate is not in the map yet
		if(coordinates.getXCoordinate() < 0) 
			while(moduloX > this.map.getNegativeSize())
				add(new Axis<Cell>(CellFactory.getNewUnseenCell()), this.map, true);
		
		//Adds unseen cells to the tail of the x axis if the coordinate is not in the map yet
		if(coordinates.getXCoordinate() > 0)
			while(coordinates.getXCoordinate() > this.map.getPositiveSize())
				add(new Axis<Cell>(CellFactory.getNewUnseenCell()), this.map, false);
		
		
		//Same thing for the corresponding y axis
		Axis<Cell> yAxis = this.map.get(coordinates.getXCoordinate());
		
		if(coordinates.getYCoordinate() < 0)
			while(moduloY > yAxis.getNegativeSize())
				add(CellFactory.getNewUnseenCell(), yAxis, true);
		
		if(coordinates.getYCoordinate() > 0)
			while(coordinates.getYCoordinate() > yAxis.getPositiveSize())
				add(CellFactory.getNewUnseenCell(), yAxis, false);
		
		//Once the map is guaranteed to contain the coordinates of the cell, update/add the cell
		yAxis.update(cell, coordinates.getYCoordinate());
		//Update map information regarding dispensers/goals
		updateMapInformation(cell, coordinates);
	}
	
	//Merging another map containing agent2 to the current map containing agent1,
	//where seenAgent2 represents the coordinates of agent2 w.r.t. agent1
	public void mergeMaps(String agent1, Coordinates seenAgent2, OurMap map2, String agent2) {
		//Step 1. Get the coordinates of agent1, and compute the coordinates of agent2 wrt the origin of map1
		Coordinates agent1Coordinates = this.agents2coordinates.get(agent1);
		
		int agent2Map1X = agent1Coordinates.getXCoordinate() + seenAgent2.getXCoordinate();
		int agent2Map1Y = agent1Coordinates.getYCoordinate() + seenAgent2.getYCoordinate();
		
		Coordinates agent2Map2Coordinates = map2.getAgentCoordinates(agent2);
		
		//Step 2. Compute the coordinates of the origin of map2 wrt to map1
		int map2OriginX = agent2Map1X - agent2Map2Coordinates.getXCoordinate();
		int map2OriginY = agent2Map1Y - agent2Map2Coordinates.getYCoordinate();
		
		//Step 3. Add all the cells in map2 to map1 (converting coordinates accordingly)
		//NOTE: there is no need to go through the list of dispensers/goals in map2 as they
		//are going to be added to map1 while adding the cells
		Axis<Axis<Cell>> mapToMerge = map2.getMap();
		
		for(int i = - mapToMerge.getNegativeSize(); i <= mapToMerge.getPositiveSize(); i++) {
			Axis<Cell> yAxis = mapToMerge.get(i);
			for(int j = - yAxis.getNegativeSize(); j <= yAxis.getPositiveSize(); j++) {
				Cell cell = yAxis.get(j);
				Coordinates newCoordinates = new Coordinates(i + map2OriginX, j + map2OriginY);
				this.updateCell(cell, newCoordinates);
			}
		}
		
		//Add all the agents in map2 to map1 (updating their coordinates in the process)
		Set<String> agentsInMap2 = map2.getAgents();
		
		for(String agent : agentsInMap2) {
			Coordinates c = map2.getAgentCoordinates(agent);
			Coordinates newCoordinates = new Coordinates(c.getXCoordinate() + map2OriginX, c.getYCoordinate() + map2OriginY);
			this.updateAgentCoordinates(agent, newCoordinates);
		}
	}
	
	//Auxiliary method for the method getSuccessors
	private void addSuccessor(Coordinates succCoordinates, Cell cell, List<Coordinates> list) {
		if(cell != null && cell.isSeen() && !cell.isWall())
			list.add(succCoordinates);
	}
	
	
	//Returns the list of neighbouring cells that are not unseen or walls
	public List<Coordinates> getSuccessors(Coordinates node){
		Coordinates north = new Coordinates(node.getXCoordinate(), node.getYCoordinate() - 1);
		Coordinates east = new Coordinates(node.getXCoordinate() + 1, node.getYCoordinate());
		Coordinates south = new Coordinates(node.getXCoordinate(), node.getYCoordinate() + 1);
		Coordinates west = new Coordinates(node.getXCoordinate() - 1, node.getYCoordinate());
		List<Coordinates> resultingList = new LinkedList<Coordinates>();
		
		Cell tmpCell = getCell(north);
		
		addSuccessor(north, tmpCell, resultingList);
		
		tmpCell = getCell(east);
		
		addSuccessor(east, tmpCell, resultingList);
		
		tmpCell = getCell(south);
		
		addSuccessor(south, tmpCell, resultingList);
		
		tmpCell = getCell(west);
		
		addSuccessor(west, tmpCell, resultingList);
		
		return resultingList;
	}
	
	//Method to return the cell in the map at some given coordinate. Returns null if the cell is not in the map
	public Cell getCell(Coordinates coordinates) {
		
		Axis<Cell> yAxis = this.map.get(coordinates.getXCoordinate());
		
		if(yAxis == null) 
			return null;
		
		Cell cell = yAxis.get(coordinates.getYCoordinate());
		
		if(cell == null) 
			return null;
		
		return cell;
	}
	
	
	private int getManhattanDistance(Coordinates source, Coordinates destination) {
		int horizontalSteps = Math.abs(source.getXCoordinate() - destination.getXCoordinate());
		int verticalSteps = Math.abs(source.getYCoordinate() - destination.getYCoordinate());
		return (horizontalSteps + verticalSteps);
	}
	
	//A* algorithm for finding the shortest path from source to destination
	public Path search(Coordinates source, Coordinates destination) {
		PriorityQueue<Path> frontier = new PriorityQueue<Path>();
		Set<Coordinates> visited = new HashSet<Coordinates>();
		Path startingPath = new Path(source, this.getManhattanDistance(source, destination));
		frontier.add(startingPath);
		boolean pathFound = false;
		Path resultingPath = null;
		while(!frontier.isEmpty() && !pathFound) {
			Path currentPath = frontier.poll();
			if(!visited.contains(currentPath.getTerminalNode())) {
				if(currentPath.getTerminalNode().equals(destination)) {
					pathFound = true;
					resultingPath = currentPath;
					
				} else {
					List<Coordinates> successors = this.getSuccessors(currentPath.getTerminalNode());
					int pathLength = currentPath.getLength();
					visited.add(currentPath.getTerminalNode());
					
					for(Coordinates c : successors) 
						frontier.add(currentPath.addSuccessor(c, pathLength + getManhattanDistance(c, destination)));
				}
			}
		}
		
		if(pathFound)
			return resultingPath;
		
		return null;
	}
	
	
	//Auxiliary method for printing the map
	private void printRow(int minX, int maxX) {
		for(int i = minX; i <= maxX; i++)
			System.out.print("---");
		System.out.println("-");
	}
	
	//returning the name of the agent at specific coordinates or null otherwise
	private String agentAtCoordinates(Coordinates coordinates) {
		for(String agent : this.knownAgents)
			if(coordinates.equals(this.agents2coordinates.get(agent)))
				return agent;
		
		return null;
	}
	
	//You can guess
	public void printMap() {
		int minX = - this.map.getNegativeSize();
		int maxX = this.map.getPositiveSize();
		int minY = - this.map.getAxis().get(0).getNegativeSize();
		int maxY = this.map.getAxis().get(0).getPositiveSize();
		
		for(Axis<Cell> yAxis : this.map.getAxis()) {
			if(-yAxis.getNegativeSize() < minY)
				minY = - yAxis.getNegativeSize();
			if(yAxis.getPositiveSize() > maxY)
				maxY = yAxis.getPositiveSize();
		}
		
		System.out.println("Printing current map.");
		System.out.println("Size: minX: " + minX + ", maxX: " + maxX + ", minY: " + minY + ", maxY: " + maxY);
		System.out.println();
		
		
		
		this.printRow(minX, maxX);
		for(int i = minY; i <= maxY ; i++) {
			for(int j = minX; j <= maxX; j++) {
				System.out.print("|");
				String agentName = agentAtCoordinates(new Coordinates(j, i)); 
				if(agentName != null)
					System.out.print(agentName);
				else {
					Cell cell = this.getCell(new Coordinates(j, i));
					if(cell != null)
						cell.print();
					else
						System.out.print("  ");
				}
			}
			System.out.println("|");
			this.printRow(minX, maxX);
		}
		
		System.out.println();
		System.out.println("Known Agents");
		for(String agent : this.knownAgents) {
			Coordinates c = this.agents2coordinates.get(agent);
			System.out.println(agent + ": " + c.toString());
		}
		System.out.println();
		
		System.out.println("Known Dispensers");
		for(String key : this.knownDispenserTypes) {
			System.out.println(key + ":");
			for(Coordinates c : this.dispenserType2coordinate.get(key))
				System.out.println(c.toString());
			System.out.println();
		}
		
		System.out.println("Known Goals");
		for(Coordinates c : this.knownGoalPositions)
			System.out.println(c.toString());
	}
}
