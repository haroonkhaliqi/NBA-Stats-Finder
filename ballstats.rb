require "http"
require "tty-prompt"
require 'tty-table'

system "clear"

prompt = TTY::Prompt.new
pastel = Pastel.new
puts pastel.decorate(" Welcome to NBA stats finder app! ", :cyan, :on_bright_white, :bold)

while true
  stats_type = ["Player Stats - Specific Player Stats", "Game Stats - All Stats for Specific Game"]
  stat = prompt.select(pastel.decorate(" Player Stats or Game Stats? ", :cyan, :on_bright_white, :bold), stats_type)

  if stat == "Player Stats - Specific Player Stats"
    puts pastel.decorate(" Enter a Player: ", :cyan, :on_bright_white, :bold)
    player = gets.chomp
    amt = player.split(" ")
    if amt.length == 1
      player = player
    else
      player = "#{amt[0]}%20#{amt[1]}"
    end


    response = HTTP.get("https://www.balldontlie.io/api/v1/players?search=#{player}")
    data = response.parse(:json)

    choices = []

    if data["data"].length > 1
      x = 0
      while x < data["data"].length
        name = "#{data["data"][x]["first_name"]} #{data["data"][x]["last_name"]}"
        choices << name
        x += 1
      end
      player = prompt.select(pastel.decorate(" Which player? ", :cyan, :on_bright_white, :bold), choices)
    end

    num = 0
    x = 0
    while x < data["data"].length
      if "#{data["data"][x]["first_name"]} #{data["data"][x]["last_name"]}" == player
        num = x
        break
      else
        x = x + 1
      end
    end

    puts prompt.yes?(pastel.decorate(" Is #{data["data"][num]["first_name"]} #{data["data"][num]["last_name"]} of the #{data["data"][num]["team"]["full_name"]} correct? ", :cyan, :on_bright_white, :bold))

    player_id = data["data"][num]["id"]

    options = ["info", "season averages"]

    option = prompt.select(pastel.decorate(" What would you like to see of #{data["data"][num]["first_name"]} #{data["data"][num]["last_name"]}? ", :cyan, :on_bright_white, :bold), options)

    if option == "info"
      table = TTY::Table.new(
        ["Info Type", "Player Info"],
        [["First Name", data["data"][num]["first_name"]], 
        ["Last_Name", data["data"][num]["last_name"]],
        ["Height", "#{data["data"][num]["height_feet"]}'#{data["data"][num]["height_inches"]}"],
        ["Weight", data["data"][num]["weight_pounds"]],
        ["Position", data["data"][num]["position"]],
        ["Team", data["data"][num]["team"]["full_name"]]]
      )

      puts table.render(:ascii)
    elsif option == "season averages"
      puts pastel.decorate(" Which NBA Season? ", :cyan, :on_bright_white, :bold)
      season = gets.chomp
      repo = HTTP.get("https://www.balldontlie.io/api/v1/season_averages?season=#{season}&player_ids[]=#{player_id}")
      season_avgs = repo.parse(:json)

      table = TTY::Table.new(
        [pastel.decorate("NBA Season Averages", :black, :on_bright_white, :bold), pastel.decorate("#{season}/#{season.to_i + 1} Season", :black, :on_bright_white, :bold)],
        [[pastel.bright_black("First Name"), pastel.cyan(data["data"][num]["first_name"])], 
        [pastel.bright_black("Last_Name"), pastel.cyan(data["data"][num]["last_name"])],
        [pastel.bright_black("Games Played"), pastel.cyan(season_avgs["data"][0]["games_played"])],
        [pastel.bright_black("Minutes Per Game"), pastel.cyan(season_avgs["data"][0]["min"])],
        [pastel.bright_black("Points Per Game"), pastel.cyan(season_avgs["data"][0]["pts"])],
        [pastel.bright_black("Assists Per Game"), pastel.cyan(season_avgs["data"][0]["ast"])],
        [pastel.bright_black("Rebounds Per Game"), pastel.cyan(season_avgs["data"][0]["reb"])],
        [pastel.bright_black("Offensive Rebounds Per Game"), pastel.cyan(season_avgs["data"][0]["oreb"])],
        [pastel.bright_black("Defensive Rebounds Per Game"), pastel.cyan(season_avgs["data"][0]["dreb"])],
        [pastel.bright_black("Field Goals Made Per Game"), pastel.cyan(season_avgs["data"][0]["fgm"])],
        [pastel.bright_black("Field Goals Attempted Per Game"), pastel.cyan(season_avgs["data"][0]["fga"])],
        [pastel.bright_black("Field Goal Percentage"), pastel.cyan(season_avgs["data"][0]["fg_pct"])],
        [pastel.bright_black("3 Pointers Made Per Game"), pastel.cyan(season_avgs["data"][0]["fg3m"])],
        [pastel.bright_black("3 Pointers Attempted Per Game"), pastel.cyan(season_avgs["data"][0]["fg3a"])],
        [pastel.bright_black("3 Point Percentage"), pastel.cyan(season_avgs["data"][0]["fg3_pct"])],
        [pastel.bright_black("Free Throws Made Per Game"), pastel.cyan(season_avgs["data"][0]["ftm"])],
        [pastel.bright_black("Free Throws Attempted Per Game"), pastel.cyan(season_avgs["data"][0]["fta"])],
        [pastel.bright_black("Free Throw Percentage"), pastel.cyan(season_avgs["data"][0]["ft_pct"])],
        [pastel.bright_black("Steals Per Game"), pastel.cyan(season_avgs["data"][0]["stl"])],
        [pastel.bright_black("Blocks Per Game"), pastel.cyan(season_avgs["data"][0]["blk"])],
        [pastel.bright_black("Turnovers Per Game"), pastel.cyan(season_avgs["data"][0]["turnover"])],
        [pastel.bright_black("Personal Fouls Per Game"), pastel.cyan(season_avgs["data"][0]["pf"])]]
      )

      puts table.render(:ascii)
    end
  elsif stat == "Game Stats - All Players Stats for Specific Game"
    puts pastel.decorate(" Enter the Home Teams Name: ", :cyan, :on_bright_white, :bold)
    team1 = gets.chomp
    puts pastel.decorate(" Enter the Opponents Team Name: ", :cyan, :on_bright_white, :bold)
    team2 = gets.chomp
    puts pastel.decorate(" Enter Which NBA Season: ", :cyan, :on_bright_white, :bold)
    nbas = gets.chomp
    rep =  HTTP.get("https://www.balldontlie.io/api/v1/teams")
    teams = rep.parse(:json)
    dataa = teams["data"]
    

    x = 0
    while x < dataa.length
      if dataa[x]["name"] == team1 || dataa[x]["full_name"] == team1
        team1id = dataa[x]["id"]
        break
      else
        x += 1
      end
    end
    y = 0
    while y < dataa.length
      if dataa[y]["name"] == team2 || dataa[y]["full_name"] == team2
        team2id = dataa[y]["id"]
        y += 1
      else
        y += 1
      end
    end

    games1 = HTTP.get("https://www.balldontlie.io/api/v1/games?per_page=100&seasons[]=#{nbas}&team_ids[]=#{team1id}")
    game1 = games1.parse(:json)

    games = []
    z = 0
    while z < game1["data"].length
      if game1["data"][z]["visitor_team"]["id"] == team2id
        game_id = game1["data"][z]["id"]
        games << game_id
      end
      z += 1
    end
    
    game_info = []
    c = 0
    while c < games.length
      inf = HTTP.get("https://www.balldontlie.io/api/v1/games/#{games[c]}")
      gam = inf.parse(:json)
      gam = {"home_team" => gam["home_team"]["full_name"], "away_team" => gam["visitor_team"]["full_name"], "home_score" => gam["home_team_score"], "away_score" => gam["visitor_team_score"], "day" => gam["date"].split[0]}
      game_info << gam
      c += 1
    end
    
    infor = []
    if game_info.length > 1
      v = 0
      while v < game_info.length
        gg = "#{game_info[v]["home_team"]} #{game_info[v]["home_score"]} vs #{game_info[v]["away_score"]} #{game_info[v]["away_team"]} on #{game_info[v]["day"]}"
        infor << gg
        v += 1
      end
      prompt.select(pastel.decorate(" Which Game? ", :cyan, :on_bright_white, :bold), infor)
    else
      puts prompt.yes?(pastel.decorate("#{game_info[0]["home_team"]} #{game_info[0]["home_score"]} vs #{game_info[0]["away_score"]} #{game_info[0]["away_team"]} on #{game_info[0]["day"]}", :cyan, :on_bright_white, :bold))
    end
  end


  ans = prompt.select(pastel.decorate(" Choose Another Player or Game? ", :cyan, :on_bright_white, :bold), %w(Yes No))
  if ans == "No"
    break
  end
end

