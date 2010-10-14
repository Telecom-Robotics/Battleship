package client;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.util.Random;

public class Player
{

	// PROTOCOL
	public static final int gridWidth = 10;
	public static final int gridHeight = 10;
	public static final String NEW_GAME = "NEWGAME";
	public static final String OK = "OK";
	public static final String SHIP = "SHIP;";
	public static final String ERR = "ERR";
	public static final String FIRE = "FIRE";
	public static final String WIN = "YOU WIN!";
	public static final String LOSE = "YOU LOSE!";
	public static final String MISSED = "RATE";
	public static final String HIT = "TOUCHE";
	public static final String HIT_AND_SANK = "TOUCHE-COULE";

	// AI's states
	public static enum State
	{
		PLACING, SHOOTING_RANDOM, SHOOTING_AROUND_SHIP, END
	};

	// AI's slot's states
	public static enum SlotState
	{
		WATER, UNKNOWN, SHIP
	};

	// AI's board
	SlotState board[][] = new SlotState[gridWidth][gridHeight];

	// AI's board
	State state = State.PLACING;

	// AI's last shoot
	int xShoot = 0;
	int yShoot = 0;

	// AI's current ship
	int xCurrentShip;
	int yCurrentShip;

	// AI's knowledge of ship's min size
	int minSize = 0;

	// AI's guessed ship orientation
	public static enum GuessedOrientation
	{
		HORIZONTAL, VERTICAL, UNKNOWN
	};

	// AI's current ship's guessed orientation
	GuessedOrientation guessedOrientation = GuessedOrientation.UNKNOWN;

	// Communication Object
	Communication communication;

	// IO strings
	String reception;
	String send;
	
	//Ships list
	ShipsSizes shipsSizes = new ShipsSizes();
	
	int currentSize = 1;
	
	boolean quitClever = false;

	public Player(InetAddress address, int port) throws IOException
	{
		communication = new Communication(new Socket(address, port));
		System.out.println("Reading to start new game on port " + port
				+ " at address " + address);

		for (int i = 0; i < gridWidth; i++)
		{
			for (int j = 0; j < gridHeight; j++)
			{
				board[i][j] = SlotState.UNKNOWN;
			}
		}
	}

	public void play()
	{
		try
		{
			Random r = new Random(System.currentTimeMillis());
			int shipWordSize = SHIP.length();
			int maxX = gridWidth;
			int maxY = gridHeight;
			String direction = "";
			boolean firstShoot = true;

			// Start
			System.out.println("Starting new game...");
			communication.send(NEW_GAME);

			// Placing ships
			while (state == State.PLACING)
			{
				reception = communication.receive();
				if (reception.equals(FIRE))
				{
					System.out.println("Beginning shooting...");
					state = State.SHOOTING_RANDOM;
				} else if (reception.equals(OK))
				{
					System.out.println("OK received.");
				} else
				{
					if (reception.equals(ERR))
					{
						System.err.println("Error received, trying again...");
					}
					if (reception.length() >= shipWordSize)
					{
						String sizeChar = reception.substring(shipWordSize);
						int size = Integer.parseInt(sizeChar);
						minSize = minSize == 0 || minSize > size ? size
								: minSize;
						shipsSizes.add(size);
						direction = r.nextInt(2) == 0 ? "H" : "V";
						maxX = gridWidth;
						maxY = gridHeight;
						if (direction.equals("H"))
							maxX -= size;
						else
							maxY -= size;
					}
					int x = r.nextInt(maxX);
					int y = r.nextInt(maxY);
					send = SHIP + x + ";" + y + ";" + direction;
					communication.send(send);
				}
			}

			// Shooting at the opponent
			while (state == State.SHOOTING_RANDOM
					|| state == State.SHOOTING_AROUND_SHIP)
			{
				if (reception.equals(FIRE))
				{
					// System.out.println("-----State : "+state+"
					// "+guessedOrientation);
					System.out.println("Choosing a shooting spot...");
					while (board[xShoot][yShoot] != SlotState.UNKNOWN
							|| firstShoot)
					{
						firstShoot = false;
						switch (state)
						{
						case SHOOTING_RANDOM:
							xShoot = r.nextInt(gridWidth);
							yShoot = r.nextInt(gridHeight);
							//int randomX = xShoot;
							//int randomY = yShoot;
							while (!intelligentSpot(xShoot, yShoot, minSize,
									quitClever)
									|| board[xShoot][yShoot] != SlotState.UNKNOWN)
							{
								xShoot = r.nextInt(gridWidth);
								yShoot = r.nextInt(gridHeight);
							}
							break;

						case SHOOTING_AROUND_SHIP:
							if (guessedOrientation == GuessedOrientation.VERTICAL)
							{
								tryVertical(true);
							} else if (guessedOrientation == GuessedOrientation.HORIZONTAL)
							{
								tryHorizontal(true);
							} else
							{
								System.err
										.println("Shooting around without direction !");
								System.exit(1);
							}
							break;
						}
					}

					if (board[xShoot][yShoot] != SlotState.UNKNOWN
							&& state != State.SHOOTING_RANDOM)
					{
						System.err
								.println("I choosed an already known spot ! Damn it...");
						System.exit(1);
					}

					send = FIRE + ";" + xShoot + ";" + yShoot;

					communication.send(send);
					reception = communication.receive();
				} else
				{
					reception = communication.receive();
				}

				if (reception.equals(WIN))
				{
					System.out.println("VICTORY !");
					state = State.END;
				} else if (reception.equals(LOSE))
				{
					System.out.println("GAME OVER");
					state = State.END;
				} else if (reception.equals(MISSED))
				{
					System.out.println("Position ( " + xShoot + ", " + yShoot
							+ " ) missed.");
					board[xShoot][yShoot] = SlotState.WATER;
				} else if (reception.equals(HIT))
				{
					System.out.println("Hit !");
					board[xShoot][yShoot] = SlotState.SHIP;
					if (guessedOrientation == GuessedOrientation.UNKNOWN)
					{
						System.out.println("It's a new boat");
						guessedOrientation = GuessedOrientation.HORIZONTAL;
						state = State.SHOOTING_AROUND_SHIP;
						xCurrentShip = xShoot;
						yCurrentShip = yShoot;
					}
				} else if (reception.equals(HIT_AND_SANK))
				{
					board[xShoot][yShoot] = SlotState.SHIP;
					System.out.println("Ship successfully sank !");

					//TODO Uncomment in case of spaces between ships...
					/*
					int size = validateShip();
					shipsSizes.removeOne(size);
					minSize = shipsSizes.getMin();
					*/

					state = State.SHOOTING_RANDOM;
					guessedOrientation = GuessedOrientation.UNKNOWN;
				}
			}
		} catch (IOException e)
		{
			e.printStackTrace();
		}
	}

	@SuppressWarnings("unused")
	private int validateShip()
	{
		int size = 1;
		if (guessedOrientation == GuessedOrientation.HORIZONTAL)
		{
			int x = xCurrentShip;
			int y = yCurrentShip;
			while (board[x][y] == SlotState.SHIP)
			{
				x++;
				if (x >= gridWidth)
				{
					x = xCurrentShip;
					break;
				} else
				{
					size++;
				}
			}
			while (board[x][y] == SlotState.SHIP)
			{
				x--;
				if (x < 0)
				{
					x = xCurrentShip;
					break;
				} else
				{
					size++;
				}
			}
		} else if (guessedOrientation == GuessedOrientation.VERTICAL)
		{
			if (guessedOrientation == GuessedOrientation.HORIZONTAL)
			{
				int x = xCurrentShip;
				int y = yCurrentShip;
				while (board[x][y] == SlotState.SHIP)
				{
					y++;
					if (y >= gridHeight)
					{
						y = yCurrentShip;
						break;
					} else
					{
						size++;
					}
				}
				while (board[x][y] == SlotState.SHIP)
				{
					y--;
					if (y < 0)
					{
						y = yCurrentShip;
						break;
					} else
					{
						size++;
					}
				}
			}
		}
		return size;
	}

	private void tryVertical(boolean first)
	{
		System.out.println("I want to do it vertically...");
		xShoot = xCurrentShip;
		yShoot = yCurrentShip;
		System.out.println("Starting at " + xShoot + " " + yShoot);
		while (board[xShoot][yShoot] == SlotState.SHIP)
		{
			yShoot++;
			if (yShoot >= gridHeight)
			{
				yShoot = yCurrentShip;
				break;
			} else
				System.out.println(xShoot + " " + yShoot + " : "
						+ board[xShoot][yShoot]);
		}
		if (board[xShoot][yShoot] != SlotState.UNKNOWN)
		{
			yShoot = yCurrentShip;
		}
		while (board[xShoot][yShoot] == SlotState.SHIP)
		{
			yShoot--;
			if (yShoot < 0)
			{
				yShoot = yCurrentShip;
				break;
			} else
				System.out.println(xShoot + " " + yShoot + " : "
						+ board[xShoot][yShoot]);
		}
		if (board[xShoot][yShoot] != SlotState.UNKNOWN)
		{
			System.out.println("I guessed wrong, so bad...");
			guessedOrientation = GuessedOrientation.VERTICAL;
			state = State.SHOOTING_AROUND_SHIP;
			if (first)
				tryHorizontal(false);
			else
			{
				System.err
						.println("Tried everything since beginning without success...");
				System.exit(1);
				/*
				quitClever = true;
				state = State.SHOOTING_RANDOM;
				*/
			}
		}
	}

	private void tryHorizontal(boolean first)
	{
		System.out.println("I want to do it horizontally...");
		xShoot = xCurrentShip;
		yShoot = yCurrentShip;
		System.out.println("Starting at " + xShoot + " " + yShoot);
		while (board[xShoot][yShoot] == SlotState.SHIP)
		{
			xShoot++;
			if (xShoot >= gridWidth)
			{
				xShoot = xCurrentShip;
				break;
			} else
				System.out.println(xShoot + " " + yShoot + " : "
						+ board[xShoot][yShoot]);
		}
		if (board[xShoot][yShoot] != SlotState.UNKNOWN)
		{
			xShoot = xCurrentShip;
		}
		while (board[xShoot][yShoot] == SlotState.SHIP)
		{
			xShoot--;
			if (xShoot < 0)
			{
				xShoot = xCurrentShip;
				break;
			} else
				System.out.println(xShoot + " " + yShoot + " : "
						+ board[xShoot][yShoot]);
		}
		if (board[xShoot][yShoot] != SlotState.UNKNOWN)
		{
			System.out.println("I guessed wrong, so bad...");
			state = State.SHOOTING_AROUND_SHIP;
			guessedOrientation = GuessedOrientation.HORIZONTAL;
			if (first)
				tryVertical(false);
			else
			{
				System.err
						.println("Tryed everything since beginning without success...");
				System.exit(1);
			}
		}
	}

	/**
	 * return true if and only if the spot is "clever"
	 * 
	 * @param x
	 * @param y
	 * @param size
	 * @return
	 */
	private boolean intelligentSpot(int x, int y, int size, boolean alwaysTrue)
	{
		if (alwaysTrue)
			return true;
		boolean xOK = (int) ((x - y) / size) * size == (x - y);
		boolean yOK = (int) ((y - x) / size) * size == (y - x);
		return xOK && yOK;
	}
}
