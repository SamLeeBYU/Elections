import requests
import difflib
import pandas as pd

def get_country_code(response, country_name):

    #We need to make sure that the African and Arab nations have appropriately matched country codes. The API and difflib does its best to match the country string, but really really only care about our countries of interest;
    #There are other country strings that I don't bother to make sure they are appropriately matched (but this doesn't matter after we filter to the African and Arab nations).

    if country_name == "United Rep. of Tanzania" or country_name == "United Republic of Tanzania":
        country_name = "Tanzania"
    if country_name == "Iran (Islamic Rep. of)" or country_name == "Iran (Islamic Republic of)":
        country_name = "Iran"
    if country_name == "Libyan Arab Jamahiriya":
        country_name = "Libya"
    if country_name == "Côte d'Ivoire" or country_name == "Cote d'Ivoire":
        country_name = "Ivory Coast"
    if country_name == "Zaire":
        country_name = "Republic of the Congo"
    if country_name == "Republic of Korea":
        country_name = "South Korea"
    if country_name == "Syrian Arab Republic":
        country_name = "Syria"
    if country_name == "Dem. Republic of the Congo" or country_name == "Democratic Republic of the Congo":
        country_name = "DR Congo"

    if response.status_code == 200:

        data = response.json()

        try:
            matches = difflib.get_close_matches(country_name, [country['name']['common'] for country in data], n=1)
            if matches:
                matched_country = matches[0]
                for country in data:
                    if country['name']['common'] == matched_country:
                        country_code = country['cca3']
                        return country_code
            else:
                print(f"Country not found: {country_name}")
                return ""
        except Exception as error:
            print(f"Country not found: {country_name}")
            return ""
        
if __name__ == "__main__":
    url = "https://restcountries.com/v3.1/all"
    response = requests.get(url)

    ipu_data = pd.read_csv("Data/IPU.csv")
    ipu_data = ipu_data[["Country","LowerElection","LowerSeats","LowerWomen","LowerPercWomen","UpperHouseSenate","UpperSeats","UpperWomen","UpperPercWomen","IPUUpdate"]].copy()
    codes = []
    for country in list(set(ipu_data["Country"].values)):
        code = get_country_code(response, country)
        codes.append(code)
    
    code_df = pd.DataFrame({
        "Country": list(set(ipu_data["Country"].values)),
        "countrycode": codes
    })

    ipu_data = ipu_data.merge(code_df, on="Country", how="left")

    ipu_data.to_csv("Data/IPU.csv", index=False)
    print("Data successfully updated.")