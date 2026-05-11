import pandas as pd
import requests
import time
import re
from io import StringIO
from bs4 import BeautifulSoup, Comment

def clean_columns(columns): #this function will allow us to handle instances where our column headers are tuples and we want to clean them up to make them easier to work with. We will check if the column header is a tuple and if it is we will check if the first element of the tuple contains "Unnamed" and if it does we will use the second element of the tuple as the column name, otherwise we will concatenate the two elements of the tuple with an underscore in between to create the column name. If the column header is not a tuple we will just use it as is.
    new_columns = []

    for col in columns:
        if isinstance(col, tuple):
            if "Unnamed" in col[0]:
                new_columns.append(col[1])
            else:
                new_columns.append(f"{col[0]}_{col[1]}")
        else:
            new_columns.append(col)
    return new_columns

def find_advanced_table( tables):
    required_cols = { #we dont need all these columns but the table will contain these so we can verify that is the correct one
        "Team",
        "W",
        "L",
        "PW",
        "PL",
        "MOV",
        "SOS",
        "SRS",
        "ORtg",
        "DRtg",
        "NRtg",
        "Pace",
        "Offense Four Factors_eFG%",
        "Defense Four Factors_DRB%",
    }
    for i, table in enumerate(tables):
        table = table.copy()
        table.columns = clean_columns(table.columns)
        table_cols = set(table.columns)

        if required_cols.issubset(table_cols):
            print(f"Found advanced stats table at index {i}" )
            return table
        
    raise ValueError( "Advanced stats table not found")

def find_playoff_table (tables): #the playoff series on basketball reference are denoted by the text X team "over" Y team, so we need to find where on the page has this sort of result
    for i, table in enumerate(tables):
        table = table.copy()

        #convert table into a string and check if it contains the text "over"
        table_text = table.astype(str).to_string()
        if " over " in table_text:
            print(f"Found playoff table at index {i}")
            return table
    raise ValueError("Playoff table not found") 

def parse_playoff_series( playoff_table, year):
    playoff_results = {}
    round_map = {
        "First Round" : 1,
        "Conference Semifinals": 2,
        "Conference Finals": 3,
        "Finals": 4
    }
    for _, row in playoff_table.iterrows():
        row_text = " ".join([str(value) for value in row.tolist()])
        #print(row_text)

        match = re.search(
            r"((?:Eastern Conference |Western Conference )?(?:First Round|Conference Semifinals|Conference Finals)|Finals)\s+(.+?)\s+over\s+(.+?)\s+\((\d+)-(\d+)\)",
        row_text
        )

        if not match:
            continue

        round_name = match.group(1).strip()
        winner = match.group(2).strip()
        loser = match.group(3).strip()
        winner_wins = int(match.group(4))
        loser_wins = int(match.group(5))

        if "First Round" in round_name:
            round_reached = 1
        elif "Conference Semifinals" in round_name:
            round_reached = 2
        elif "Conference Finals" in round_name:
            round_reached = 3
        elif round_name == "Finals":
            round_reached = 4

        #determine which round was reached based on the row text
        #round_reached = round_map[round_name]
        #for round_name, round_num in round_map.items():
         #   if round_name in row_text:
                #round_reached = round_num
                #break
        for team in [winner, loser]:
            if team not in playoff_results:
                playoff_results[team] = {
                    "Team": team,
                    "Season": year,
                    "Playoff_Wins" : 0,
                    "Playoff_Losses": 0,
                    "Round_Reached": 0,
                    "Finals_Appearance": 0,
                    "Championship": 0
                }
        playoff_results[winner]["Playoff_Wins"] += winner_wins #this is how they are called on the basketball reference site
        playoff_results[winner]["Playoff_Losses"] += loser_wins
        playoff_results[loser]["Playoff_Wins"] += loser_wins
        playoff_results[loser]["Playoff_Losses"] += winner_wins

        playoff_results[winner] ["Round_Reached"] = max(playoff_results[winner]["Round_Reached"], round_reached)
        playoff_results[loser] ["Round_Reached"] = max(playoff_results[loser]["Round_Reached"], round_reached)

        if round_reached == 4:
            playoff_results[winner]["Finals_Appearance"] = 1
            playoff_results[loser]["Finals_Appearance"] = 1
            playoff_results[winner]["Championship"] = 1
    return pd.DataFrame(playoff_results.values())


def get_all_tables_from_page(html):
    soup = BeautifulSoup(html, "html.parser")
    comments = soup.find_all(string=lambda text: isinstance(text, Comment))

    for comment in comments:
        comment_soup = BeautifulSoup(comment, "html.parser")
        comment.replace_with(comment_soup)

    return pd.read_html(StringIO(str(soup)))

print("Running the correct scraper file") #this is just to verify I was using the correct file as there were save issues before

#url = "https://www.basketball-reference.com/leagues/NBA_2006.html"
#the webscraping has to be done like this to get past the website blocking the request.
headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}

#response = requests.get(url, headers=headers)

#print("Status code:", response.status_code) #checking that our request was successful; should return 200

#tables = pd.read_html(StringIO(response.text))

#tables = get_all_tables_from_page(response.text)

#print(f"Number of tables found: {len(tables)}")

#for i, table in enumerate(tables):
 #   print(f"\n--- Table {i} ---")
#    print(table.columns.tolist())

# Table 8 appears to be the Miscellaneous Stats / Advanced Team Stats table.
# We will print the first few rows to verify that it matches the website.
#advanced_stats = find_advanced_table(tables) #this is the advanced stats table we want to scrape however in later seasons the table number changes so we neeed to update the code to include a function that will find the table to use

#print("\nAdvanced stats before cleaning column names:")
#print(advanced_stats.head())

# Some of the column headers are tuples so we need to clean them to make it easier to work with. We will make this conditional however because not all columns are tuples.
#advanced_stats.columns = [
 #   col[1] if "Unnamed" in col[0] else f"{col[0]}_{col[1]}"
  #  for col in advanced_stats.columns
#]
#advanced_stats.columns = clean_columns(advanced_stats.columns)

#print("\nAdvanced stats columns after cleaning:")
#print(advanced_stats.columns.tolist())

#print("\nAdvanced stats preview after cleaning:")
#print(advanced_stats.head()) #gets the first 5 rows of the advanced stats table to verify that we have the correct data

#now we know that the webscraping is working and we have the correct table, we can begin building a loop that will iterate through all the seasons and scrape the advanced stats for each season and build the table of data we want to use. 

# we need to clean up some of the names in the results as well as on basketball reference an * is used to denote the playoff teams, so we will need to remove that from the team names as well.
#advanced_stats["Team"] = advanced_stats["Team"].str.replace("*", "", regex=False)

#Some NBA teams have changed names and locations so we will need to map the team names to their current 2025-2026 season names
team_name_map = {
    "Seattle SuperSonics": "Oklahoma City Thunder",
    "New Jersey Nets": "Brooklyn Nets",
    "Charlotte Bobcats": "Charlotte Hornets",
    "New Orleans Hornets": "New Orleans Pelicans",
    "New Orleans/Oklahoma City Hornets": "New Orleans Pelicans",
    "Vancouver Grizzlies": "Memphis Grizzlies"
}

#advanced_stats["Franchise"] = advanced_stats["Team"].replace(team_name_map)

#now we want to get the columns we want to use for our analysis and create a new dataframe with just those columns.
#advanced_stats = advanced_stats[
    #[
    #"Team",
    #"Franchise",
    #"W",
    #"ORtg",
    #"DRtg",
    #"NRtg",
    #"SRS",
    #"Pace",
    #"Offense Four Factors_eFG%",
    #"Offense Four Factors_ORB%",
    #"Offense Four Factors_TOV%",
   # "Defense Four Factors_DRB%",
  #  "Defense Four Factors_TOV%"
 #   ]
#]
#advanced_stats["Season"] = 2006

#print(advanced_stats.head()) #making sure we have the correct columns and data before we move on to building the loop to scrape all the seasons.

#begin iterating through the seasons and scraping the data for each season and appending it to a list of dataframes that we will concatenate at the end to create our final dataframe of all the advanced stats for all the seasons.
all_seasons = [] #this table will contain advanced stats for the regular season for 2006- 2025
all_playoffs =[] #this table will contain playoff series results for 2006-2025

for year in range(2006, 2026):
    url = f"https://www.basketball-reference.com/leagues/NBA_{year}.html"
# i removed the headers from the loop because we can just set it once at the beginning of the script and it will be used for all the requests in the loop.
    response = requests.get(url, headers=headers)
    response.raise_for_status() #this will raise an error if the request was not successful for some reason so we can catch it and handle it instead of just getting a blank page or something like that.
    tables = get_all_tables_from_page(response.text)
    print(f"Scraping season {year}...")
    advanced_stats = find_advanced_table(tables)
    #advanced_stats.columns = clean_columns(advanced_stats.columns) - we dont need this because the find_advanced_table function already cleans the column names for us now.
    advanced_stats["Team"] = advanced_stats["Team"].str.replace("*", "", regex=False)
    advanced_stats["Franchise"] = advanced_stats["Team"].replace(team_name_map)
    advanced_stats = advanced_stats [advanced_stats["Team"] != "League Average"] #removing the league average row from the table as we dont need it for our analysis and it will just add unnecessary rows to our final dataframe.
    advanced_stats = advanced_stats[
    [
    "Team",
    "Franchise",
    "W",
    "ORtg",
    "DRtg",
    "NRtg",
    "SRS",
    "Pace",
    "Offense Four Factors_eFG%",
    "Offense Four Factors_ORB%",
    "Offense Four Factors_TOV%",
    "Defense Four Factors_DRB%",
    "Defense Four Factors_TOV%"
    ]
]
    advanced_stats["Season"] = year
    all_seasons.append(advanced_stats)
    print(f"Finished scraping season {year}") #get all the data we need for regular season, then we will start parsing the playoff series results

    playoff_table = find_playoff_table(tables)
    playoff_stats = parse_playoff_series(playoff_table, year)
    all_playoffs.append(playoff_stats)

    time.sleep(5) #sleeping for 5 second between requests to avoid getting blocked by the website for making too many requests in a short period of time and follow TOS

final_advanced_stats = pd.concat(all_seasons, ignore_index=True)
print(final_advanced_stats.head()) #checking that we have the correct data for all the seasons before we save it to a csv file.
print(final_advanced_stats.shape) #checking the shape of the final dataframe to make sure we have the correct number of rows and columns before we save it to a csv file.

final_playoff_stats = pd.concat(all_playoffs, ignore_index=True)

print("Playoff columns:", final_playoff_stats.columns.tolist()) #checking the columns in the playoff stats dataframe to make sure we have the correct data before we save it to a csv file.
print("Playoff shape:", final_playoff_stats.shape) #checking the shape of the playoff stats dataframe to make sure we have the correct number of rows and columns before we save it to a csv file.


final_playoff_stats["Team"] = final_playoff_stats["Team"].str.replace("*", "", regex=False) #removing the * from the team names in the playoff stats as well to make sure they match the team names in the advanced stats dataframe so we can merge them later on.
final_playoff_stats["Franchise"] = final_playoff_stats["Team"].replace(team_name_map) #adding the franchise column to the playoff stats dataframe as well so we can merge on that later on as well if we want to do some analysis at the franchise level instead of the team level.

print(final_playoff_stats.head()) #checking that we have the correct data for all the seasons before we save it to a csv file.
print(final_playoff_stats.shape) #checking the shape

final_advanced_stats.to_csv("nba_advanced_stats_2006_2025.csv", index=False) #saving the final dataframe to a csv file so we can use it for our analysis in the future without having to scrape the data again.    
print("2006-2025 NBA advanced stats saved to nba_advanced_stats_2006_2025.csv")

final_playoff_stats.to_csv("nba_playoff_results_2006_2025.csv", index=False) #saving the final dataframe to a csv file so we can use it for our analysis in the future without having to scrape the data again.   
print("2006-2025 NBA playoff results saved to nba_playoff_results_2006_2025.csv")

final_playoff_stats = final_playoff_stats.drop(columns = ["Team"])

#now we have two csv files with the data we want, we can combine these in SQL but we can also just merge them here as well. 
final_dataset = final_advanced_stats.merge(
    final_playoff_stats, 
    on=["Season", "Franchise"],
      how="left") #merging the two dataframes on the Franchise and season columns to create our final dataset that we will use for our analysis. We will do a left merge because we want to keep all the teams in the advanced stats dataframe and just add the playoff results for the teams that made the playoffs. The teams that did not make the playoffs will have NaN values for the playoff results columns which we can fill with 0s later if we want to.


playoff_cols = [
    "Playoff_Wins",
    "Playoff_Losses",
    "Round_Reached",
    "Finals_Appearance",
    "Championship"
]
final_dataset[playoff_cols] = final_dataset[playoff_cols].fillna(0) #filling the NaN values in the playoff results columns with 0s
final_dataset.to_csv("nba_final_dataset_2006_2025.csv", index=False) #saving the final dataset to a csv file so we can use it for our analysis in the future without having to merge the data again.
print("Final dataset with advanced stats and playoff results saved to nba_final_dataset_2006_2025.csv")

print( "Job done")
