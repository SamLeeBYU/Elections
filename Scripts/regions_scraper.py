import requests
from bs4 import BeautifulSoup
import pandas as pd

url = "https://www.state.gov/countries-and-areas-list"

response = requests.get(url)

if response.status_code == 200:

    soup = BeautifulSoup(response.text, 'html.parser')

    container = soup.find('div', class_='entry-content')

    regions = []
    countries = []

    for region in container.find_all('div', class_='state-countries-areas-list-block'):
        region_name = region.find('h2', class_='country-list__title').text.strip()

        country_list = [country.text.strip() for country in region.find_all('li')]

        regions.extend([region_name] * len(country_list))
        countries.extend(country_list)

    df = pd.DataFrame({'Region': regions, 'Country': countries})
    df.to_csv("Data/regions.csv", index=False)
    print("Data successfully saved to directory.")