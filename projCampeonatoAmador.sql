--create database CampeonatoAmador
use CampeonatoAmador

create table Teams
(
    [name] varchar(30),
    nickname varchar(30),
    CreationDate date,
    goalsScored int,
    goalsConceded int,
    points int,
    wins int,

    constraint PK_Teams primary key ([name])
)
GO

create table Games
(
    id int IDENTITY(1,1),
    -- identificação da partida
    teamA varchar(30),
    -- primeiro time
    teamB varchar(30),
    -- segundo time
    stadium varchar(30),
    -- estádio vai receber o apelido do time da casa
    winner varchar(30),
    -- gols A - Gols B  
    goalsScoredA int,
    -- gols feitos por A == gols sofridos por B
    goalsConcededA int,
    -- gols sofridos por A == gols feitos por B
    totalGoals int,
    -- gols A + gols B

    constraint PK_Game  primary key (id),
    constraint FK_GameA foreign key (teamA) references Teams,
    constraint FK_GameB foreign key (teamB) references Teams
)
 go

-- criação dos 5 times que irão jogar entre si
INSERT INTO Teams
    ([name], nickname, CreationDate)
VALUES('Corinthians', 'Timão', '1910-09-01');
INSERT INTO Teams
    ([name], nickname, CreationDate)
VALUES('Palmeiras', 'Porco', '1914-08-26' );
INSERT INTO Teams
    ([name], nickname, CreationDate)
VALUES('São Paulo', 'O Mais Querido', '1930-01-25');
INSERT INTO Teams
    ([name], nickname, CreationDate)
VALUES('Flamengo', 'Malvadão', '1912-05-03' );
INSERT INTO Teams
    ([name], nickname, CreationDate)
VALUES('Cruzeiro', 'Rei de copas', '1921-01-02');
go

update teams set goalsScored = 0, goalsConceded = 0, points = 0, wins = 0
go 

-- criação dos jogos:
                   --@stadium              @nameA         @nameB         @goalsScoredAInGame / @goalsConcededAInGame 
EXEC.GameBetweenTeams 'Timão',          'Corinthians',  'Cruzeiro',       3 , 1
EXEC.GameBetweenTeams 'Timão',          'Corinthians',  'Flamengo',       0 , 0
EXEC.GameBetweenTeams 'Timão',          'Corinthians',  'Palmeiras',      1 , 5
EXEC.GameBetweenTeams 'Timão',          'Corinthians',  'São Paulo',      2 , 2

EXEC.GameBetweenTeams 'Rei De Copas',   'Cruzeiro',     'Flamengo',       3 , 2
EXEC.GameBetweenTeams 'Rei De Copas',   'Cruzeiro',     'Palmeiras',      4 , 1
EXEC.GameBetweenTeams 'Rei De Copas',   'Cruzeiro',     'São Paulo',      3 , 3

EXEC.GameBetweenTeams 'Malvadão' ,      'Flamengo',     'Palmeiras',      2 , 3
EXEC.GameBetweenTeams 'Malvadão' ,      'Flamengo',     'São Paulo',      2 , 1

EXEC.GameBetweenTeams 'Porco' ,         'Palmeiras',    'São Paulo',      3 , 1

-- troca de estádios

EXEC.GameBetweenTeams 'Rei de Copas',   'Cruzeiro',     'Corinthians',    2 , 1

EXEC.GameBetweenTeams 'Malvadão',       'Flamengo',     'Cruzeiro',       1 , 1
EXEC.GameBetweenTeams 'Malvadão',       'Flamengo',     'Corinthians',    2 , 3

EXEC.GameBetweenTeams 'Porco',          'Palmeiras',    'Cruzeiro',       5 , 3
EXEC.GameBetweenTeams 'Porco',          'Palmeiras',    'Flamengo',       4 , 1 
EXEC.GameBetweenTeams 'Porco',          'Palmeiras',    'Corinthians',    1 , 0

EXEC.GameBetweenTeams 'O Mais Querido', 'São Paulo',    'Corinthians',    2 , 4
EXEC.GameBetweenTeams 'O Mais Querido', 'São Paulo',    'Cruzeiro',       3 , 2
EXEC.GameBetweenTeams 'O Mais Querido', 'São Paulo',    'Flamengo',       2 , 1
EXEC.GameBetweenTeams 'O Mais Querido', 'São Paulo',    'Palmeiras',      1 , 2
go




--------------------------------------------------------------------------------------------------------------------------
CREATE or alter TRIGGER TGR_totalGoals_insert on Games after insert
AS
BEGIN
    declare @teamA varchar(30), @teamB varchar(30), @goalsScoredA int, @goalsConcededA int, @totalGoals int

    select @teamA = teamA, @teamB = teamB, @goalsScoredA = goalsScoredA, @goalsConcededA = goalsConcededA FROM INSERTED 

    SET @totalGoals = @goalsScoredA + @goalsConcededA
    update games set totalGoals = @totalGoals where teamA = @teamA and teamB = @teamB
end
go


---------------------------------------------------------------------------------------------------------------------------

-- PROCEDURE para definir as variáveis do jogo 
CREATE OR ALTER PROCEDURE GameBetweenTeams
    @stadium varchar(30),
    @nameA varchar(30),
    @nameB varchar(30),
    @goalsScoredAInGame int,  --gols feitos pelo time A nesse jogo = gols tomados pelo time B 
    @goalsConcededAInGame int --gols tomados pelo time A nesse jogo = gols feitos pelo time B 
-- parâmetros da procedure
as
begin
    declare @pointsA int, @pointsB int, @winner varchar(30), @winsA int, @winsB int,
            @totalGoalsScoredA int, @totalGoalsConcededA int, @nicknameA varchar(30),
            @totalGoalsScoredB int, @totalGoalsConcededB int, @nicknameB varchar(30), @idGame int

    select @pointsA = points, @totalGoalsScoredA = goalsScored, @totalGoalsConcededA = goalsConceded, @nicknameA = nickname, @winsA = wins
    from Teams
    where [name] = @nameA
    --acumulação dos pontos e total de gols feitos e sofridos pelo time A

    select @pointsB = points , @totalGoalsScoredB = goalsScored, @totalGoalsConcededB = goalsConceded, @nicknameB = nickname, @winsB = wins
    from Teams
    where [name] = @nameB
    --acumulação dos pontos e total de gols feitos e sofridos pelo time B 

    select @winner = winner, @idGame = id
    from Games
    where id = @idGame
    -- total de gols nessa partida(de ambos os times) e vencedor

     -- agregando os gols no total de gols de cada time
    set @totalGoalsScoredA += @goalsScoredAInGame
    set @totalGoalsConcededA += @goalsConcededAInGame

    IF (@goalsScoredAInGame - @goalsConcededAInGame > 0 )
    BEGIN
        set @winner = @nameA
        set @winsA += 1

        IF(@stadium = @nicknameA)
            set  @pointsA += 3      -- pontuação se A for vencedor e dono do estádio
        ELSE
            set @pointsA += 5
    -- pontuação se A for vencedor e visitante
    END

    IF (@goalsScoredAInGame - @goalsConcededAInGame < 0 )
    BEGIN
        SET @winner = @nameB
        set @winsB += 1


        IF(@stadium = @nicknameB)  
            set  @pointsB += 3      -- pontuação se B for vencedor e dono do estádio
        ELSE
            set @pointsB += 5
    -- pontuação se B for vencedor e visitante
    END

    IF(@goalsScoredAInGame - @goalsConcededAInGame = 0)    -- EMPATE
    begin
        set @winner = 'EMPATE'
        set @pointsA += 1
        set @pointsB += 1
    end

    insert into Games
          ( teamA,  teamB,  stadium,  winner,  goalsScoredA,        goalsConcededA      )
    values(@nameA, @nameB, @stadium, @winner, @goalsScoredAInGame, @goalsConcededAInGame)

    UPDATE Teams set goalsScored = @totalGoalsScoredA,   goalsConceded = @totalGoalsConcededA, points = @pointsA, wins = @winsA  WHERE [name] = @nameA
    UPDATE Teams set goalsScored = @totalGoalsConcededA, goalsConceded = @totalGoalsScoredA,   points = @pointsB, wins = @winsB  WHERE [name] = @nameB
   
end;
go

select* from Teams
select* from Games
go

---------------------------------------------------------------------------------------------------------------------------

CREATE or alter PROCEDURE SetChampion
AS
BEGIN
       
    DECLARE @points int, @name varchar(30), @aux varchar(30), @champion int

    SELECT top 1 @points= points , @name = [name] from Teams ORDER by points DESC

    SELECT @aux= [name] from Teams where points=@points

    if(@name!=@aux)
    BEGIN
        SELECT top 1 @champion= wins , @name=[name] from Teams ORDER by points DESC
        SELECT @aux= [name] from Teams where wins = @champion

        if(@name!=@aux)
            SELECT top 1 [name], points from Teams where points=@points order by (GoalsScored -GoalsConceded) desc
        else
            SELECT top 1 [name], points from Teams where points=@points order by wins desc
    END
    else
        SELECT top 1 name, points from Teams ORDER by points DESC

end;
go

---------------------------------------------------------------------------------------------------------------------------

-- 5 primeiros times do campeonato
select [name] from Teams 
go

---------------------------------------------------------------------------------------------------------------------------

-- time com mais vitórias
declare @name varchar(30)
select top 1 @name = [name] from Teams order by wins desc
print('O time com mais vitórias é o ' + @name)
go


---------------------------------------------------------------------------------------------------------------------------

-- time com mais gols feitos
declare @name varchar(30)
select top 1 @name = [name] from Teams order by goalsScored desc
print('O time que mais fez gols foi o ' + @name)
go

---------------------------------------------------------------------------------------------------------------------------

-- time com mais gols tomados
declare @name varchar(30)
select top 1 @name = [name] from Teams order by goalsConceded desc
print('O time que mais tomou gols foi o ' + @name)
go

---------------------------------------------------------------------------------------------------------------------------

-- maior número de gols que cada time fez em um único jogo

-- corinthians
declare @goalsScoredInGame int
select top 1 @goalsScoredInGame = goalsScoredA from Games where teamA = 'Corinthians' order by goalsScoredA desc  
print('Maior número de gols feitos pelo Corinthians em um único jogo neste campeonato:')
print(@goalsScoredInGame)
go

-- cruzeiro
declare @goalsScoredInGame int
select top 1 @goalsScoredInGame = goalsScoredA from Games where teamA = 'Cruzeiro' order by goalsScoredA desc  
print('Maior número de gols feitos pelo Cruzeiro em um único jogo neste campeonato:')
print(@goalsScoredInGame)
go

-- flamengo
declare @goalsScoredInGame int
select top 1 @goalsScoredInGame = goalsScoredA from Games where teamA = 'Flamengo' order by goalsScoredA desc  
print('Maior número de gols feitos pelo Flamengo em um único jogo neste campeonato:')
print(@goalsScoredInGame)
go

-- palmeiras
declare @goalsScoredInGame int
select top 1 @goalsScoredInGame = goalsScoredA from Games where teamA = 'Palmeiras' order by goalsScoredA desc  
print('Maior número de gols feitos pelo Palmeiras em um único jogo neste campeonato:')
print(@goalsScoredInGame)
go

-- são paulo
declare @goalsScoredInGame int
select top 1 @goalsScoredInGame = goalsScoredA from Games where teamA = 'São Paulo' order by goalsScoredA desc  
print('Maior número de gols feitos pelo São Paulo em um único jogo neste campeonato:')
print(@goalsScoredInGame)
go

---------------------------------------------------------------------------------------------------------------------------

exec.SetChampion