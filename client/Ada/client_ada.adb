with Ada.Text_IO; use Ada.Text_IO;
with Sockets; use Sockets;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Sockets.Stream_IO; use Sockets, Sockets.Stream_IO;

procedure Client_ada is

  Server_Name : String := "v12.rezel.net";

  type Ship is record 
    X : Integer;
    Y : Integer;
    orientation : character;
  end record;


  type Ship_Placement is array(1..5) of Ship;
  placement1 : Ship_Placement := ((0,0,'V'),(1,0,'V'),(2,0,'V'),(3,0,'V'),(4,0,'V'));

  Current_ship : Integer := 0;
  Current_line : Integer := 0;
  Current_column : Integer := 0;
  Current_step : Integer := 1;

  Outgoing_Socket : Socket_FD;
  Stream          : aliased Socket_Stream_Type;

  New_Game : constant String := "NEWGAME";
  Reception : Unbounded_String := null_unbounded_string;

  function Strip_Leading_Blank (Str : String)
    return String is
  begin -- Strip_Leading_Blank
    if Str (Str'First) = ' ' then
      return Str (1+Str'First .. Str'Last);
    else
      return Str;
    end if;
  end Strip_Leading_Blank;

begin

  Socket (Outgoing_Socket, PF_INET, SOCK_STREAM);
  Connect (Outgoing_Socket, "v12.rezel.net", 1235);  
  Put_Line("create_socket SUCCESS");
  Initialize (Stream, Outgoing_Socket);
  Put_Line("test");
  Flush;
  Put_Line(Outgoing_Socket,"NEWGAME");
  Put_Line("Newgame envoye");


  loop
    Reception := To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
    Put_Line(To_String(Reception));

    if (Reception = "FIRE") then
      exit;
    elsif (Reception = "SHIP;5" or else Reception = "SHIP;4" or else Reception = "SHIP;3" or else Reception = "SHIP;2") then

      Put_Line(Strip_leading_Blank(Integer'Image(placement1(Current_ship+1).X))&Strip_Leading_Blank(Integer'Image(placement1(Current_ship+1).Y))&placement1(Current_ship+1).orientation);
      --Put_Line(Integer'Image(placement1(Current_ship+1).X));

      Put_Line(Outgoing_Socket,"SHIP;"&Strip_leading_Blank(Integer'Image(placement1(Current_ship+1).X))&";"&Strip_Leading_Blank(Integer'Image(placement1(Current_ship+1).Y))&";"&placement1(Current_ship+1).orientation);
      Reception := To_Unbounded_String(Get_Line(Outgoing_Socket,2048));

      if(Reception = "OK") then
        Current_ship := (Current_ship + 1) mod 5;
        Put_Line("Placement bateau effectue");
      elsif(Reception = "ERR") then
        Put_Line("erreur placement bateau");
      else
        Put_Line("erreur dans le protocole");
      end if;
    end if; 
  end loop;    

  loop
    if(Reception = "FIRE") then
      Put_Line("recu FIRE");
      Put_Line(Outgoing_Socket,"FIRE;"&(Strip_Leading_Blank(Integer'Image(Current_line)))&";"&Strip_Leading_Blank(Integer'Image(Current_column)));
      Reception:=To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
      Put_Line("je viens de recevoir");
      if (Reception = "OK") then
        Current_column := Current_column + Current_step;
        if(Current_column >= 10) then
          Put_Line("recu OK");
          Current_line := Current_line + 1;
          Current_column := Current_line mod Current_step;
        end if;
      elsif (Reception = "ERR") then
        Put_Line("erreur fire");	
      end if;
    elsif(Reception = "RATE") then
      Put_Line("TIR RATE");
    elsif(Reception = "TOUCHE") then
      Put_Line("TOUCHE");
    elsif(Reception = "TOUCHE-COULE") then
      Put_Line("TOUCHE-COULE");
    elsif(Reception = "YOU LOSE")then
      Put_Line("You LOSE !!!!!!!!!!");
      exit;
    elsif(Reception = "YOU WIN") then
      Put_Line("YOU WIN !!!!!!!!!!!");
      exit;
    end if;
      Reception:=To_Unbounded_String(Get_Line(Outgoing_Socket,2048));

  end loop;

  Put_Line("Fin de Battleship");

end Client_ada;
