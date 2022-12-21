library(RSelenium)
library(tidyverse)
library(rvest)
library(httr)

#--------------------------------------------- Page control ---------------------------------------------
# binman::list_versions("chromedriver") # "88.0.4324.27" "88.0.4324.96" "89.0.4389.23" "90.0.4430.24" "91.0.4472.19"
driver <- rsDriver(browser=c("chrome"), chromever="90.0.4430.24")
remote_driver <- driver[["client"]]
remote_driver$navigate("https://www.searates.com/")
#Sys.sleep(5)


#--------------------------------------------- Transport type ---------------------------------------------
# Sea
remote_driver$findElement(using = "css", "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._2tKN8f9SbMvwp20VOt-WfG > div > div:nth-child(1)")$clickElement()
# Land
remote_driver$findElement(using = "css", "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._2tKN8f9SbMvwp20VOt-WfG > div > div:nth-child(2)")$clickElement()
# AIR
remote_driver$findElement(using = "css", "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._2tKN8f9SbMvwp20VOt-WfG > div > div:nth-child(3)")$clickElement()




#--------------------------------------------- Textfield ---------------------------------------------
rd <- rsDriver(browser = "chrome",
               chromever='90.0.4430.24',
               remoteServerAddr = "localhost",
               port = 4567L,
               check = F
)

remote_driver<- rd$client

remote_driver$navigate("https://www.searates.com/")
remote_driver$findElement(using = 'css', value = '#from')$sendKeysToElement(list("Port Of Shanghai, China"))
remote_driver$findElement(using = 'css', value = '#to')$sendKeysToElement(list("Port Of Mersin, Turkey"))# works
Sys.sleep(2)
remote_driver$findElement(using = "css", value = "#from-autocomplete > div > div > div > div:nth-child(1)")$clickElement() # works
Sys.sleep(2)
remote_driver$findElement(using = "css", value = "#from-autocomplete > div > div > div > div.fvlk5rSgKI--Xo4zMn3an > div:nth-child(2) > div")$clickElement()


#from-autocomplete > div > div > div > div.fvlk5rSgKI--Xo4zMn3an > div:nth-child(2)
# from
remote_driver$findElement(using = 'css', value = '#from')$sendKeysToElement(list("Shanghai, China")) # works
Sys.sleep(2)
remote_driver$findElement(using = "css", value = "#from-autocomplete > div > div > div > div:nth-child(1)")$clickElement() # works
Sys.sleep(2)
remote_driver$findElement(using = "css", value = "#from-autocomplete > div > div > div > div.fvlk5rSgKI--Xo4zMn3an > div:nth-child(2)")$clickElement()

# other way
remote_driver$findElement(using = 'id', value ='from')$sendKeysToElement(list("Shanghai, China"))$clickElement()
Sys.sleep(2)  
remote_driver$findElement(using = "css", value = "#from-autocomplete [tabindex='0']")$clickElement()
Sys.sleep(2)  
remote_driver$findElement(using = "css", value = "#from-autocomplete [tabindex='1']")$clickElement()

#--------------------------------------------- Dropdown---------------------------------------------
type <- remote_driver$findElement(using = "css", value = "._2srCaT0ghjej5SIscfFely")$clickElement() # css- yazının özüdür. seçmək üçün tabı açdı
# FCL
remote_driver$findElement(using = "css", value = "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._1rqpoXVt22QKC2AMMpxbmp > div > div._3IpkWWcVWLGwZTprYrAJCa > div:nth-child(1)")$clickElement() 
# LCL
remote_driver$findElement(using = "css", value = "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._1rqpoXVt22QKC2AMMpxbmp > div > div._3IpkWWcVWLGwZTprYrAJCa > div:nth-child(2)")$clickElement() 
# Bulk
remote_driver$findElement(using = "css", value = "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._1rqpoXVt22QKC2AMMpxbmp > div > div._3IpkWWcVWLGwZTprYrAJCa > div:nth-child(3)")$clickElement() 



#--------------------------------------------- Button ---------------------------------------------
remote_driver$findElement(using = "css", "#main-filter > div > div > div._3DCtXh7PeB566R0Ry1hcgX > div:nth-child(3) > div > form > div > div._2zCOr2At1mJ0LmVg_3xIm2 > input")$clickElement() # tgrcRL9Kef-3m90nBzOxa



#--------------------------------------------- Output ---------------------------------------------
output <- remote_driver$findElement(using = "", value = "" )
output <- output$getElementText()



#================================================
#================================================
#WEB-SCRAPING ------------------------------------------------------------
# Helper functions: 
#   Establish and open remote driver connection
open.rmd <- function(){
  system("kill -9 $(lsof -ti tcp:4567)")
  rD <- rsDriver(port = 4567L, browser = "firefox")
  remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4567L, browserName = "firefox")
}

#   Convert square footage/price strings to numeric
toNum <- function(a.string){
  return(gsub("\\$|,", "", a.string) %>% as.numeric())
}

#   Close server connection
close.server <- function(){
  remDr$close()
}

# Web-scraping constants:
theURL <- "http://property.phila.gov/"
addr.selector <- "#search-address"
unit.selector <- "#search-unit"
price.xpath <- "/html/body/div[1]/main/div[3]/div[1]/div[7]/table/tbody/tr[1]/td[2]/span"
sq.footage.selector <- "div.panel:nth-child(2) > div:nth-child(6) > div:nth-child(2) > strong:nth-child(2)"

# Remote driver
open.rmd()
# Launch browser
remDr$open()

# Scrape data
for (x in 1:nrow(data)){
  
  # Navigate to the URL of the search page
  remDr$navigate(theURL)
  
  # Enter address field
  addressField <- remDr$findElement("css selector", addr.selector)
  addressField$sendKeysToElement(list(data$address[x]))
  
  # Enter unit number
  unitField <- remDr$findElement("css selector", unit.selector)
  unitField$sendKeysToElement(list(data$unit[x]))
  
  # Search for property
  addressField$sendKeysToElement(list(key = 'enter'))
  
  # Wait for page to load
  Sys.sleep(1.5)
  
  # Find the price element with xpath
  price <- remDr$findElement("xpath", price.xpath)
  # Find the square footage with css selector
  square.foot <- remDr$findElement("css selector", sq.footage.selector)
  
  # Assign the price to the appropriate cell in the data frame
  data$valuation[x] <- price$getElementText() %>% 
    unlist %>% 
    toNum()
  
  # Assign the sq. footage to the appropriate cell in the data frame
  data$square.footage[x] <- square.foot$getElementText() %>% 
    unlist() %>% 
    toNum()
  
  # Calculate price per sq foot
  data$pp.sqft[x] <- data$valuation[x] / data$square.footage[x]
  
  # Log loop progress to console
  print(paste("Completed scraping ", x, " of ", "[", nrow(data), "]", sep = ""))
}

# close server
close.server()
