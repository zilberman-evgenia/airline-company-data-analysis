#Write a parser to collect data about 11 biggest festivals of 2018. Save the data to the festivals dataframe and display it on the screen.
#Website link: https://code.s3.yandex.net/learning-materials/data-analyst/festival_news/index.html


import requests
import pandas as pd
from bs4 import (
    BeautifulSoup,
) 

URL = "https://code.s3.yandex.net/learning-materials/data-analyst/festival_news/index.html"
req = requests.get(URL)
soup = BeautifulSoup(req.text, 'lxml')
table = soup.find('table',attrs={'id': 'best_festivals'})

heading_table = [] 
for row in table.find_all('th'):
        heading_table.append(row.text)        

content=[] 
for row in table.find_all('tr'): 
    if not row.find_all('th'): 
            content.append([element.text for element in row.find_all('td')])  

festivals = pd.DataFrame(data = content, columns = heading_table) 
print(festivals) 