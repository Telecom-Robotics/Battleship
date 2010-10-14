package client;

import java.util.ArrayList;

@SuppressWarnings("serial")
public class ShipsSizes extends ArrayList<Integer>
{
	public boolean removeOne(int value)
	{
		for (int i=0; i<this.size(); i++)
		{
			if ((Integer)(this.get(i)) == value)
			{
				remove(i);
				return true;
			}
		}
		return false;
	}
	
	public int getMin()
	{
		int min = get(0);
		for (int i=1; i<this.size(); i++)
		{
			if (get(i) < min)
			{
				min = get(i);
			}
		}
		return min;
	}
}
