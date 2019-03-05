# Connect to the database
con = dbConnect(RSQLite::SQLite(),dbname='medicare.sqlite')
rs = dbSendQuery(con, "SELECT * FROM medicare") 
data = dbFetch(rs)
data$zip = clean.zipcodes(data$ZIP.Code)
data(zipcode)
data=merge(data,zipcode,by.x="zip",by.y="zip")
data$latlon = paste(data$latitude,data$longitude)

df = data %>%
  select(City,State,latitude,longitude,Score,Compared.to.National,Measure.Name,Hospital.Name,ZIP.Code,latlon,Address,Phone.Number) %>%
  mutate(Measure.Split = Measure.Name) %>%
  separate(Measure.Split,c("Infection","Metric"),extra='merge',fill='right') %>%
  filter(Score != 'Not Available')
rm(data)
