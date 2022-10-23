----------------------------DROP Tables before starting in case they already exists
USE [Juegos Olimpicos]

DROP TABLE Competiciones
DROP TABLE Competidores
DROP Table Deportes
DROP TABLE Eventos
DROP TABLE Juegos
DROP TABLE Medallas
DROP TABLE Paises
DROP TABLE Ciudades
DROP TABLE Temporadas

/*
-----------------------RAW TABLES

SELECT *
FROM [dbo].[athlete_events$]

SELECT *
FROM [dbo].[noc_regions]
*/

-----------------------Paises Table Creation
CREATE TABLE Paises(
	 Id_Pais int identity (1,1) primary key
	,Nombre varchar(50) NOT NULL
	,NOC varchar(5) NOT NULL
	)

INSERT INTO Paises
SELECT DISTINCT region,NOC
FROM [dbo].[noc_regions]

-----------------------Ciudades Table Creation
CREATE TABLE Ciudades(
	 Id_Ciudad int identity (1,1) primary key
	,Nombre varchar(50) NOT NULL
	)

INSERT INTO Ciudades
SELECT DISTINCT City
FROM [dbo].[athlete_events$]

-----------------------Temporadas Table Creation
CREATE TABLE Temporadas(
	 Id_Temporada int identity (1,1) primary key
	,Nombre varchar(50) NOT NULL
	)

INSERT INTO Temporadas
SELECT DISTINCT Season
FROM [dbo].[athlete_events$]

-----------------------Juegos Table Creation
CREATE TABLE Juegos(
	 Id_Juego int identity (1,1) primary key
	,Cod_Ciudad int  FOREIGN KEY (Cod_Ciudad) REFERENCES Ciudades (Id_Ciudad) -- FK
	,Cod_Temporada int FOREIGN KEY (Cod_Temporada) REFERENCES Temporadas (Id_Temporada) -- FK
	,anio int NOT NULL
	)

INSERT INTO Juegos
SELECT DISTINCT C.Id_Ciudad
			   ,T.Id_Temporada
			   ,Year
FROM [dbo].[athlete_events$] RAW
	INNER JOIN Temporadas T
		ON RAW.Season = T.Nombre
	INNER JOIN Ciudades C
		ON RAW.City = C.Nombre

-----------------------Deportes Table Creation
CREATE TABLE Deportes(
	 Id_Deporte int identity (1,1) primary key
	,Nombre varchar(100) NOT NULL
	)

INSERT INTO Deportes
SELECT DISTINCT Sport
FROM [dbo].[athlete_events$]

-----------------------Eventos Table Creation
CREATE TABLE Eventos(
	 Id_Evento int identity (1,1) primary key
	,Nombre varchar(100) NOT NULL
	)

INSERT INTO Eventos
SELECT DISTINCT Event
FROM [dbo].[athlete_events$]

-----------------------Medallas Table Creation
CREATE TABLE Medallas(
	Id_Medalla int identity (1,1) primary key
	,Descripcion varchar(20) NOT NULL
	)

INSERT INTO Medallas
SELECT DISTINCT Medal
FROM [dbo].[athlete_events$]
WHERE Medal <> 'NA'

-----------------------Competidores Table Creation
CREATE TABLE Competidores(
	 Id int identity (1,1) primary key
	,Nombre varchar(150) NOT NULL
	,Sexo varchar(1) NOT NULL
	,Altura int
	,Peso int
	,Cod_Pais Int FOREIGN KEY (Cod_Pais) REFERENCES Paises (Id_Pais) -- FK
)

INSERT INTO Competidores
SELECT DISTINCT RD.Name
			   ,RD.Sex
			   ,RD.Height
			   ,RD.Weight
			   ,P.Id_Pais
FROM [dbo].[athlete_events$] RD
	INNER JOIN Paises P
		ON RD.NOC = P.NOC

-----------------------Competiciones Table Creation
CREATE TABLE Competiciones(
	Cod_Juego int FOREIGN KEY (Cod_Juego) REFERENCES Juegos (Id_Juego)--fk 
	,Cod_Competidor int FOREIGN KEY (Cod_Competidor) REFERENCES Competidores (Id)--fk
	,Edad_Competidor Int
	,Cod_Deporte int FOREIGN KEY (Cod_Deporte) REFERENCES Deportes (Id_Deporte)--fk
	,Cod_Evento int FOREIGN KEY (Cod_Evento) REFERENCES Eventos (Id_Evento)--fk
	,Cod_Medalla int FOREIGN KEY (Cod_Medalla) REFERENCES Medallas (Id_Medalla)--fk
	)

INSERT INTO Competiciones
SELECT DISTINCT J.Id_Juego
	  ,C.Id
	  ,RD.Age
	  ,D.Id_Deporte
	  ,E.Id_Evento
	  ,M.Id_Medalla
FROM [dbo].[athlete_events$] RD
	INNER JOIN Juegos J
		ON RD.Year = J.Anio AND J.Cod_Temporada = (SELECT Te.Id_Temporada FROM Temporadas Te WHERE Te.Nombre = RD.Season)
	INNER JOIN Deportes D
		ON RD.Sport = D.Nombre
	INNER JOIN Eventos E
		ON RD.Event = E.Nombre
	INNER JOIN Competidores C
		ON RD.Name = C.Nombre
	LEFT JOIN Medallas M
		ON RD.Medal = M.Descripcion
	INNER JOIN Temporadas T
		ON RD.Season = T.Nombre

