#Script to scrape historic CO2 emissions for African and Arab nations.
#Need to run regions_scraper.py before hand to get Data/regions.csv

import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime
from dateutil.relativedelta import relativedelta
import numpy as np
import time

#import selenium libraries
from selenium import webdriver
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.action_chains import ActionChains

#Create the chrome driver that can be referred to globally
driver = None
actions = None

def selenium_driver():
    global driver
    global actions
    
    service = Service(ChromeDriverManager(driver_version="123.0.6312.60").install())

    options = Options()
    driver = webdriver.Chrome(service=service, options=options)
    actions = ActionChains(driver)

class Scraper():
    
    def __init__(self, url):
        #Define the url to scrape
        self._url = url
        self.go(self._url)

        #Aggregate the data to this variable
        self._Data = pd.DataFrame()

        self.regions = pd.read_csv("Data/regions.csv")
        region_subset = self.regions[(self.regions["Region"] == "Near East (Middle East and Northern Africa)") | (self.regions["Region"] == "Sub-Saharan Africa")]
        self.country_regions = region_subset["Region"].values
        self.countries = region_subset["Country"].values
        self.country_codes = []

    @property
    def Data(self):
        return self._Data

    def go(self, url):
        driver.get(url)

    def query(self, country):
        #Make sure our data matches with EDGAR country spellings:
        if country == 'Côte d’Ivoire':
            country = 'Côte d`Ivoire'
        elif country == 'Republic of the Congo':
            country = 'Congo'
        elif country == 'Sao Tome and Principe':
            country = 'São Tomé and Príncipe'
        #We will ultimately make these countries 'the same' in our final data set
        elif country == 'Sudan' or country == 'South Sudan':
            country = 'Sudan and South Sudan'
        elif country == 'Israel' or country == 'Palestinian Territories':
            country = 'Israel and Palestine, State of'

        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "country_select"))
        )
        query_box = driver.find_element(By.ID, "country_select")
        country_options = query_box.find_elements(By.TAG_NAME, "option")
        country_texts = np.array([option.text for option in country_options])
        country_values = [option.get_attribute("value") for option in country_options]

        index = np.argwhere(country_texts == country)[0][0]
        self.country_codes.append(country_values[index])

        Select(query_box).select_by_value(country_values[index])

    @staticmethod
    def query_data():
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "select-sub"))
        )
        #Select CO2 emissions
        Select(driver.find_element(By.ID, "select-sub")).select_by_value("1")
        
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "chart1"))
        )
        chart = driver.find_element(By.ID, "chart1")
        actions.move_to_element(chart).perform()
        link_access = False
        while not link_access:
            try:
                if len(chart.find_elements(By.CLASS_NAME, "wt-link")) > 0:
                    link_access = True
                else:
                    link_access = False
            except Exception as error:
                link_access = False
            time.sleep(0.5)
        chart.find_element(By.CLASS_NAME, "wt-btn").click()
        link = chart.find_elements(By.CLASS_NAME, "wt-link")[0]
        link.click()

    def scrape_data(self, country):
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.TAG_NAME, "table"))
        )
        table_loaded = False
        while not table_loaded:
            try:
                table = driver.find_element(By.TAG_NAME, "table").find_elements(By.TAG_NAME, "tr")
                #2022-1970 = 53 (inclusive) (+1 header row) = 54 (We should have 54 rows altogether when the table loads)
                if len(table) >= 54:
                    table_loaded = True
                else:
                    table_loaded = False
            except Exception as error:
                table_loaded = False
        html = driver.page_source
        data = pd.read_html(html)[0]
        data["Country"] = country
        if self._Data.empty:
            self._Data = data
        else:
            self._Data = pd.concat([self._Data, data]).reset_index(drop=True)
        self.go(self._url)

    def save_data(self, dir="Data"):
        self._Data = self._Data.rename(columns={'Category': 'Year'})

        region_subset = pd.DataFrame({"Region": self.country_regions, "Country": self.countries, "countrycode": self.country_codes})
        region_subset = region_subset.drop_duplicates(subset=['countrycode']).reset_index(drop=True)

        self._Data = pd.merge(region_subset, self._Data, on='Country', how='left')

        self._Data.to_csv(f"{dir}/emissions.csv", index=False)
        print("Data successfully saved to the directory.")

    def main_loop(self):
        for country in self.countries:
            self.query(country)
            self.query_data()
            self.scrape_data(country)
            if country == self.countries[-1]:
                self.save_data()
        

if __name__ == "__main__":
    selenium_driver()

    scraper = Scraper("https://edgar.jrc.ec.europa.eu/country_profile")
    scraper.main_loop()