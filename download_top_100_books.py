# %% Initiate
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import time
import pandas as pd
import urllib.request

# %%
driver = webdriver.Chrome('C:/Users/xx/Documents/chromedriver/chromedriver.exe')  # Optional argument, if not specified will search path.

# %% Go to webpage of 100 best books
driver.get('https://www.goodreads.com/list/show/6')
time.sleep(5)

# %% Scrap 100 best books
pageSource = driver.page_source
bs = BeautifulSoup(pageSource, "lxml")
tbl = bs.find(id="all_votes").find('table').find('tbody')
titles_authors = tbl.find_all(itemprop='name')

df = pd.DataFrame(index=range(0, 100), columns=['Title', 'Author', 'Results', 'FoundAuthor', 'FoundTitle','href'])

for i in range(0, 100):
    s = str(titles_authors[i*2])
    start = s.find('>')+1
    end = s.find('<', start)
    title = s[start:end]
    
    # After the bracket there is nothing interesting anyway
    start_bracket = title.find('(')
    if start_bracket>0:
        title = title[:start_bracket]
    
    s = str(titles_authors[i*2+1])
    start = s.find('>')+1
    end = s.find('<', start)
    author = s[start:end]    
    
    df.Title[i] = title
    df.Author[i] = author

# %% Scrap 500 best books
    
for page in range(2, 6):
    driver.get('https://www.goodreads.com/list/show/6.Best_Books_of_the_20th_Century?page='+str(page))    
    time.sleep(5)
    
    pageSource = driver.page_source
    bs = BeautifulSoup(pageSource, "lxml")
    tbl = bs.find(id="all_votes").find('table').find('tbody')
    titles_authors = tbl.find_all(itemprop='name')
    
    df2 = pd.DataFrame(index=range(0, 100), columns=['Title', 'Author', 'Results', 'href'])

    for i in range(0, 100):
        s = str(titles_authors[i*2])
        start = s.find('>')+1
        end = s.find('<', start)
        title = s[start:end]
        
        # After the bracket there is nothing interesting anyway
        start_bracket = title.find('(')
        if start_bracket>0:
            title = title[:start_bracket]
        
        s = str(titles_authors[i*2+1])
        start = s.find('>')+1
        end = s.find('<', start)
        author = s[start:end]    
        
        df2.Title[i] = title
        df2.Author[i] = author
    
    df = pd.concat([df, df2])

df = df.reset_index(drop=True)
# %% Check if these books are available on Gutenberg
driver.get('https://www.gutenberg.org/wiki/Main_Page')
time.sleep(2)

for i in range(0, 500):
    author = df.Author[i]
    title = df.Title[i]
    if i == 0:
        find_field = driver.find_element_by_id("menu-book-search")
    else:
        find_field = driver.find_element_by_id("search-input")
    find_field.clear()
    find_field.send_keys(author + ' ' + title)
    find_field.send_keys(Keys.RETURN)
    time.sleep(2)
    pageSource = driver.page_source
    bs = BeautifulSoup(pageSource, "lxml")
    results = bs.find("ul", class_="results")
    first_info = results.find_all("span", class_="title")[0].extract()
    first_info = str(first_info.contents)
    if first_info == "['No records found.']":
        df.Results[i] = first_info
    else:
        booklink = results.find("li", class_="booklink")
        try:
            found_title = booklink.find_all("span", class_="title")[0].extract()
            found_title = str(found_title.contents)
            start = found_title.find("'")+1
            end = found_title.find("'", start)
            stripped_title = found_title[start:end]
            df.FoundTitle[i] = stripped_title
        except:
            found_title = ''
        try:
            found_author = booklink.find_all("span", class_="subtitle")[0].extract()
            found_author = str(found_author.contents)
            start = found_author.find("'")+1
            end = found_author.find("'", start)
            stripped_author = found_author[start:end]
            df.FoundAuthor[i] = stripped_author
        except:
            found_author = ''
        found_link = booklink.find_all("a", href=True)[0]
        found_link = found_link['href']
        df.Results[i] = found_author + ': ' + found_title
        df.href[i] = found_link

# %% Inspect if these books exist
df = df[['Author', 'Title', 'Results', 'FoundAuthor', 'FoundTitle', 'href']]
df['is_found'] = (df.Author == df.FoundAuthor) & (df.Title == df.FoundTitle)
df = df.fillna(value={'is_found':False})

sum(df.is_found)     # 13 = za mało :(

df2 = df.loc[~df['href'].isna()]
df2 = df2.reset_index(drop=True)

df2.loc[2, 'is_found'] = True
df2.loc[18, 'is_found'] = True
df2.loc[21, 'is_found'] = True
df2.loc[23, 'is_found'] = True
df2.loc[26, 'is_found'] = True
df2.loc[33, 'is_found'] = True


for i in range(0, len(df2)):
    if df2.is_found[i] == False:
        driver.get("https://www.gutenberg.org"+df2.href[i])
        pageSource = driver.page_source
        bs = BeautifulSoup(pageSource, "lxml")
        results = bs.find("div", class_="header")
        title_by_author = results.find_all("h1")[0].extract()
        title_by_author = str(title_by_author.contents)
        title_by_author = title_by_author.replace(" ", "")
        title_by_author = title_by_author.replace("\\","")
        if title_by_author == ("['" + df2.Title[i] + " by " + df2.Author[i] + "']").replace(" ", ""):
            df2.loc[i, 'is_found'] = True
        
    if df2.is_found[i] == True:
        id_i = df2.href[i][8:]
        try:
            testfile = urllib.request.urlretrieve("https://www.gutenberg.org/ebooks/"+str(id_i)+".txt.utf-8", "D:/WNE/DS/Projects/Ksiazki/"+str(id_i)+".txt")
        except:
            testfile = urllib.request.urlretrieve("https://www.gutenberg.org/files/"+str(id_i)+"/"+str(id_i)+"-0.txt", "D:/WNE/DS/Projects/Ksiazki/"+str(id_i)+".txt")
        
        
# %% Cleanup
driver.close()
driver.quit()
