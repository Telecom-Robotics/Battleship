package client;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class MainClient
{
	public static void main(String[] args)
	{
		if (args.length != 2)
		{
			System.err.println("Use : address port");
			System.exit(1);
		}
		
		String address = args[0];
		int port = Integer.parseInt(args[1]);
		
		try
		{
			Player player = new Player(InetAddress.getByName(address), port);
			player.play();
		}
		catch (UnknownHostException e)
		{
			System.err.println("Unknown host");
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
