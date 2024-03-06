import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime
from dateutil.relativedelta import relativedelta

#import selenium libraries
from selenium import webdriver
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

def selenium_driver():
    
    service = Service(ChromeDriverManager(driver_version="121.0.6167.189").install())

    options = Options()
    driver = webdriver.Chrome(service=service, options=options)
    return driver

#Create the chrome driver that can be referred to globally
driver = None

class Scraper():
    
    def __init__(self, url):
        #Define the url to scrape
        self._url = url
        self.go(self._url)
        self._urls = []
        self._finished_archive = False

        #Aggregate the data to this variable
        self._Data = pd.DataFrame()

    @property
    def Data(self):
        return self._Data

    def go(self, url):
        driver.get(url)

    @staticmethod
    def get_next_month(d):
        d = d + relativedelta(months=1)
        return d

    def scrape_urls(self):
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.TAG_NAME, "table"))
        )
        table = driver.find_element(By.TAG_NAME, "table")
        links = table.find_elements(By.CSS_SELECTOR, "tr a")
        for i in range(len(links)-1, 3, -1):
            self._urls.append(links[i].get_attribute("href"))

    def scrape_table(self, currentUrl):
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.TAG_NAME, "table"))
        )
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        table = soup.find_all('table')[2]
        data = pd.read_html(str(table))[0].iloc[2:, 1:]
        IPUUpdate = datetime.strptime(currentUrl.split("classif")[1].split(".htm")[0], '%d%m%y').date()
        if IPUUpdate == datetime(1999, 12, 25).date():
            data = data.drop(data.columns[5], axis=1)
        data.columns = ["Country", "LowerElection", "LowerSeats", "LowerWomen", "LowerPercWomen", "UpperHouseSenate", "UpperSeats", "UpperWomen", "UpperPercWomen"]
        
        data["IPUUpdate"] = IPUUpdate
        
        if self._Data.empty:
            self._Data = data
        else:
            self._Data = pd.concat([self._Data, data]).reset_index(drop=True)

    def scrape_modern(self, date):
        WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.TAG_NAME, "table"))
        )
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        table = soup.find('table')
        data = pd.read_html(str(table))[0].iloc[2:, 1:]
        data.columns = ["Country", "LowerElection", "LowerSeats", "LowerWomen", "LowerPercWomen", "UpperHouseSenate", "UpperSeats", "UpperWomen", "UpperPercWomen"]
    
        data["IPUUpdate"] = date
        
        if self._Data.empty:
            self._Data = data
        else:
            self._Data = pd.concat([self._Data, data]).reset_index(drop=True)

    def save_data(self, dir="Data"):
        self._Data.to_csv(f"{dir}/IPU.csv", index=False)
        print("Data successfully saved to the directory.")

    def main_loop(self):
        global driver
        self.scrape_urls()
        for i in range(len(self._urls)):
            if not self._finished_archive:
                self.go(self._urls[i])
                self.scrape_table(self._urls[i])
                if i == len(self._urls)-1:
                    self._finished_archive = True

        today = datetime.now().date()
        today_params = {"month": today.month, "year": today.year}

        date = datetime.strptime(self._urls[len(self._urls)-1].split("classif")[1].split(".htm")[0], '%d%m%y').date()
        date = self.get_next_month(date)
        params = {"month": date.month, "year": date.year}

        while params != today_params:
            driver = selenium_driver()
            self.go(f"https://data.ipu.org/women-ranking?month={params['month']}&year={params['year']}")
            self.scrape_modern(date)

            date = self.get_next_month(date)
            params = {"month": date.month, "year": date.year}
        driver = selenium_driver()
        self.go(f"https://data.ipu.org/women-ranking?month={today_params['month']}&year={today_params['year']}")
        self.scrape_modern(today)

        self.save_data()
            
if __name__ == "__main__":
    driver = selenium_driver()

    scraper = Scraper("http://archive.ipu.org/wmn-e/classif-arc.htm")
    scraper.main_loop()