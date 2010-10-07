with Ada.Text_IO; use Ada.Text_IO;
with Sockets; use Sockets;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;

with Sockets.Stream_IO; use Sockets, Sockets.Stream_IO;

procedure Client_ada is

  Server_Name : String := "v12.rezel.net";

  --Type des bateaux
  type Ship is record
        X : Integer;
        Y : Integer;
        orientation : Integer;
  end record;

  Bateau : Ship;

  Current_ship : Integer := 0;
  Current_line : Integer := 0;
  Current_column : Integer := 0;
  Current_step : Integer := 1;

  Outgoing_Socket : Socket_FD;
  Stream          : aliased Socket_Stream_Type;

  New_Game : constant String := "NEWGAME";
  Reception : Unbounded_String := null_unbounded_string;

  --Type taille tableau
  type Taille is range 0..9;

  package Hazard is new Ada.Numerics.Discrete_Random (Taille);
  use Hazard;
  G : Generator;

  --Type cases potentielles
  type Cases is array (1..100) of Integer;

  --Stocke les coordonnées des cases à chercher autours les bateaux détectés
  AChercherX : Cases := (others => -1);
  AChercherY : Cases := (others => -1);
  NombreAChercher : Integer := 0;

  --Type Matrice Bool
  type Matrix is array (0..9, 0..9) of Boolean;

  ChampDeBataille : Matrix := (others => (others => False));
  PositionBateaux : Matrix := (others => (others => False));

  ContinuerPlacer : Boolean := True;
  ContinuerJeu : Boolean := True;
  BateauTouche : Boolean := False;
  BateauBienPlace : Boolean := False;

  LongueurBateau : Integer;
  I : Integer := 0;
  J : Integer := 0;
  Orientation : String := "H";

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
  Connect (Outgoing_Socket, "jonction", 6666);
  Put_Line("create_socket SUCCESS");
  Initialize (Stream, Outgoing_Socket);
  Put_Line("test");
  Flush;
  Put_Line(Outgoing_Socket,"NEWGAME");
  Put_Line("Newgame envoye");

  Reset(G);

  while ContinuerPlacer loop

      if Reception = "ERR" then
         Reception := To_Unbounded_String("SHIP;X");
      else
         Reception := To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
      end if;
      Put_Line(To_String(Reception));
      if Reception = "FIRE" then
         ContinuerPlacer := False;
      elsif Reception = "SHIP;5" or Reception = "SHIP;4" or Reception = "SHIP;3" or Reception = "SHIP;2" or Reception = "SHIP;X" then
      --On détermine quelle est la longueur du bateau demandé
         if Reception = "SHIP;2" then
            LongueurBateau := 2;
         elsif Reception = "SHIP;3" then
            LongueurBateau := 3;
         elsif Reception = "SHIP;4" then
            LongueurBateau := 4;
         else
            LongueurBateau := 5;
         end if;

         --On envoi des positions du bateau tant que ça plait pas au serveur
         while Reception /= "OK" and Reception /= "ERR" loop
            BateauBienPlace := False;
            while not BateauBienPlace loop --tant qu'on trouve pas une position convenable
               Bateau.X := Integer'Value(Taille'Image(Random (G)));
               Bateau.Y := Integer'Value(Taille'Image(Random (G)));
               Bateau.Orientation := Integer'Value(Taille'Image(Random (G))) / 5;
               --Note : j'ai pas trouvé d'autre moyen pour transformer le type Taille en Integer
               --que de le transformer en String, puis en Integer...
               if Bateau.Orientation = 0 then
                  Orientation := "H";
               else
                  Orientation := "V";
               end if;

               BateauBienPlace := True;
               --On vérifie qu'il est effectivement bien placé
               if Orientation = "H" then
                  if Bateau.X + LongueurBateau - 1 > 9 then
                     BateauBienPlace := False;
                  else
                     for A in 0..(LongueurBateau - 1) loop
                        if PositionBateaux(Bateau.X + A, Bateau.Y) = True then
                           BateauBienPlace := False;
                        end if;
                     end loop;
                  end if;
               elsif Orientation = "V" then
                  if Bateau.Y + LongueurBateau - 1 > 9 then
                     BateauBienPlace := False;
                  else
                     for A in 0..(LongueurBateau - 1) loop
                        if PositionBateaux(Bateau.X, Bateau.Y + A) = True then
                           BateauBienPlace := False;
                        end if;
                     end loop;
                  end if;
               end if;
            end loop;

            Put_Line("SHIP;" & Strip_Leading_Blank(Integer'Image(Bateau.X)) & ";" & Strip_Leading_Blank(Integer'Image(Bateau.Y)) & ";" & Orientation);
            Put_Line(Outgoing_Socket, "SHIP;" & Strip_Leading_Blank(Integer'Image(Bateau.X)) & ";" & Strip_Leading_Blank(Integer'Image(Bateau.Y)) & ";" & Orientation);
            Reception := To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
         end loop;
      end if;

      for A in 0..(LongueurBateau - 1) loop
         if Orientation = "H" then
            PositionBateaux(Bateau.X + A, Bateau.Y) := True;
         elsif Orientation = "V" then
            PositionBateaux(Bateau.X, Bateau.Y + A) := True;
         end if;
      end loop;
end loop;

  --Statégie
        while ContinuerJeu loop
           if Reception = "FIRE" then
              Put_Line("recu FIRE");
              Put_Line(Boolean'Image(BateauTouche));
              --On sépare les cas : si on a un bateau en ligne de mire, on cherche autour; sinon, tir aléatoire en croix
              if BateauTouche then
                 I := AChercherX(NombreAChercher);
                 J := AChercherY(NombreAChercher);
                 AChercherX(NombreAChercher) := -1;
                 AChercherY(NombreAChercher) := -1;
                 NombreAChercher := NombreAChercher - 1;
                 if NombreAChercher = 0 then
                    BateauTouche := False;
                 end if;
              else
                 --Tir aléatoire, possible seulement sur une case sur deux (sur un damier)
                 while ChampDeBataille(I,J) or not ((I + J) mod 2 = 0) loop
                    I := Integer'Value(Taille'Image(Random (G)));
                    J := Integer'Value(Taille'Image(Random (G)));
                 end loop;
              end if;
           end if;

           --On marque qu'on vient de tirer sur la case
           ChampDeBataille(I,J) := True;

           Put_Line(Outgoing_Socket,"FIRE;" & Strip_Leading_Blank(Integer'Image (I)) & ";" & Strip_Leading_Blank(Integer'Image (J)));
           Put_Line("FIRE;" & Strip_Leading_Blank(Integer'Image (I)) & ";" & Strip_Leading_Blank(Integer'Image (J)));

           Reception:=To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
           Reception:=To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
           if Reception = "TOUCHE" then --On marque le résultat
              Put_Line("touché");
              BateauTouche := True;

              --On cherche dans les cases autour
              if I < 9 and then not ChampDeBataille(I+1,J) then
                 NombreAChercher := NombreAChercher + 1;
                 AChercherX(NombreAChercher) := I+1;
                 AChercherY(NombreAChercher) := J;
              end if;
              if I > 0 and then not ChampDeBataille(I-1,J) then
                 NombreAChercher := NombreAChercher + 1;
                 AChercherX(NombreAChercher) := I-1;
                 AChercherY(NombreAChercher) := J;
                 Put_Line("Test2");
              end if;
              if J < 9 and then not ChampDeBataille(I,J+1) then
                 NombreAChercher := NombreAChercher + 1;
                 AChercherX(NombreAChercher) := I;
                 AChercherY(NombreAChercher) := J+1;
                 Put_Line("Test3");
              end if;
              if J > 0 and then not ChampDeBataille(I,J-1) then
                 NombreAChercher := NombreAChercher + 1;
                 AChercherX(NombreAChercher) := I;
                 AChercherY(NombreAChercher) := J-1;
                 Put_Line("Test4");
              end if;

           elsif (Reception = "ERR") then
              Put_Line("erreur fire");
           elsif(Reception = "RATE") then
              Put_Line("TIR RATE");
           elsif(Reception = "TOUCHE-COULE") then
              Put_Line("TOUCHE-COULE");
           end if;

           Reception:=To_Unbounded_String(Get_Line(Outgoing_Socket,2048));
           ContinuerJeu := (Reception /= "YOU WIN") and (Reception /= "YOU LOSE");
           if Reception = "YOU WIN" then
              Put_Line("Gagne");
           elsif Reception = "YOU LOSE" then
              Put_Line("Perdu");
           end if;
        end loop;


---------------------------------------------FIN STRATEGIE ---------------------------------------------------------------------------------
---------------------------------------------FIN STRATEGIE ---------------------------------------------------------------------------------
---------------------------------------------FIN STRATEGIE ---------------------------------------------------------------------------------

  Put_Line("Fin de Battleship");

end Client_ada;
