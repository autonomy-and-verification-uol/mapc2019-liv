package env.map;

import java.util.LinkedList;

/**
 * Class representing an axis
 * @author papacchf
 *
 * @param <T>
 */

public class Axis<T> {
	private int origin;
	private LinkedList<T> axis;
	
	//rather pointless constructor, but just in case we need it
	public Axis() {
		this.origin = 0;
		this.axis = new LinkedList<T>();
	}
	
	public Axis(T value){
		if(value != null) {
			this.origin = 0;
			this.axis = new LinkedList<T>();
			this.axis.add(value);
		}
		else
			new Axis<T>();
	}

	public Axis(int origin, LinkedList<T> list) {
		if(list != null && !list.isEmpty() && origin >= 0 && origin < list.size()) {
			this.origin = origin;
			this.axis = list;
		}
		else
			new Axis<T>();
	}

	//getters and setters
	
	public int getOrigin() {
		return origin;
	}

	public void setOrigin(int origin) {
		this.origin = origin;
	}

	public LinkedList<T> getAxis() {
		return axis;
	}

	public void setAxis(LinkedList<T> axis) {
		this.axis = axis;
	}
	
	//more or less serious methods
	public int getSize() {
		return this.axis.size();
	}
	
	//return the number of cells after the origin (-1 is required as the list starts from 0)
	public int getPositiveSize() {
		return this.getSize() - this.origin -1;
	}
	
	//return the number of cells before the origin
	public int getNegativeSize() {
		return this.origin;
	}
	
	//add an element at the head of the list and update the origin
	public void addFirst(T value) {
		this.axis.addFirst(value);
		this.origin++;
	}
	
	//add an element at the end of the list
	public void addLast(T value) {
		this.axis.addLast(value);
	}
	
	//Replace an existing cell with a new value
	//Assumption: the coordinate exists (checked by the map)
	//Note: the coordinate are given without knowing where the origin is, but the value is adjusted in the method
	public void update(T newValue, int coordinate) {
		this.axis.set(coordinate + this.getOrigin(), newValue);
	}
	
	//Returns the value at coordinate `coordinate' after adjusting the coordinates
	//Returns null if the coordinate are out of bounds
	public T get(int coordinate) {
		if(coordinate < 0 && Math.abs(coordinate) > this.getNegativeSize())
			return null;
		
		if(coordinate > 0 && coordinate > this.getPositiveSize())
			return null;
		
		return this.axis.get(coordinate + this.getOrigin());
	}
}
