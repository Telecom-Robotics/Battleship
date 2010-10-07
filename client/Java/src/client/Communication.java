package client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class Communication
{
	public static final String endl = "\r\n";
	
	Socket socket;
	PrintWriter output;
	BufferedReader input;

	public Communication(Socket s) throws IOException
	{
		socket = s;
		output = new PrintWriter(socket.getOutputStream());
		input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
	}
	
	public void send(String message)
	{
		System.out.println("Message sent : \""+message+"\"");
		output.println(message);
		output.flush();
	}
	
	public String receive() throws IOException
	{
		//System.out.println("Waiting for answer...");
		String reception = input.readLine();
		System.out.println("Message received : \""+reception+"\"");
		return reception;
	}
}
