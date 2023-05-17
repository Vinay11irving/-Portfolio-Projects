#Installing Required libraries

library(ggplot2)
library(maps)
library(ggthemes)

#Ingesting Raw data
raw_data <- read.csv("olympics.csv")

#Dividing dataset by gender
male_data <- raw_data[raw_data$Sex == "M",c("Name", "Sex", "Age", "Team",  "Year", "City", "Sport", "Event", "Medal")]
female_data <- raw_data[raw_data$Sex == "F",c("Name", "Sex", "Age", "Team",  "Year", "City", "Sport", "Event", "Medal")]

#Creating data set for last decade
lastdec_data <- raw_data[raw_data$Year %in% c(2000, 2004, 2008, 2012, 2016, 2020), c("Year","Sex") ]

#Creating plot for Figure 3.1 (Population change over the years)
ggplot(data = lastdec_data) + geom_bar(mapping = aes(x = Year, fill = Sex), position = "dodge") 
+ labs(y = "Number of Participants") 
+ theme(plot.margin = unit(c(1, 1, 2, 1), "lines"),axis.title.x = element_text(margin = margin(t = 10)), plot.title = element_text(hjust = 0.5)) 
+ ggtitle("Number of Participants in the Last Decade")
+ scale_x_continuous(breaks = c(2000, 2004, 2008, 2012, 2016, 2020))

#Creating subset for medals data
medal_data <- raw_data[raw_data$Medal %in% c("Gold", "Silver", "Bronze"), c("Team", "Medal", "Age", "Year")]

#Finding all unique countries
all_countries <- c(unique(raw_data$Team))
countries <- c(unique(medal_data$Team))
count_part <- numeric(1169)
count_medal <- numeric(486)

#Loop for counting number of medals each country won
for(i in 1:486){
  count_medal[i] <- nrow(medal_data[medal_data$Team == countries[i],])
}

#Data frame with country and respective medal counts
country_medal_df <- data.frame(countries,count_medal) 

#Sorting Data to find top 10 countries
data_sorted <- country_medal_df[order(-country_medal_df$count_medal),]
top_10 <- head(data_sorted, n = 10)
top_10_medals <- medal_data[medal_data$Team %in% c(top_10$countries),]

#Creating Figure 3.2(Top 10 countries winnings)
ggplot(data = top_10_medals) + geom_bar(mapping = aes(y = Team, fill = Medal)) 
+ scale_fill_manual(values = c("Gold" = "goldenrod", "Silver" = "gray", "Bronze" = "sienna")) 
+ labs(x = "Number of Medals", y = "Team")+ theme(plot.margin = unit(c(1, 1, 2, 1), "lines"),axis.title.x = element_text(margin = margin(t = 10)), plot.title = element_text(hjust = 0.5)) 
+ ggtitle("Number of Medals for Top 10 Countries")

#Preparing clean data without null values from medal data
clean_medal <- medal_data[complete.cases(medal_data$Age), ]
clean_medal <- clean_medal[clean_medal$Team %in% c(top_10$countries),]
age_groups <- unique(na.omit(medal_data$Age))

#Creating plot for figure 3.4(Does age matter to win medals)
ggplot(clean_medal, aes(x = Age, y = ..count..)) + geom_point(stat = "bin", bins = 50, position = "jitter") 
+ labs(x = "Age", y = "Number of Medals")+ theme(plot.margin = unit(c(1, 1, 2, 1), "lines"),axis.title.x = element_text(margin = margin(t = 10)), plot.title = element_text(hjust = 0.5)) 
+ ggtitle("Age vs Number of Medals")

#loop for counting number of athletes from each country
for(n in 1:1169){
  count_part[n] <- nrow(raw_data[raw_data$Team == all_countries[n],]) 
}

count_athelete <- data.frame(all_countries,count_part)
count_athelete$all_countries <- gsub("United States", "USA", count_athelete$all_countries)

#Reading world map data
world <- map_data("world")
df_map <- merge(world, count_athelete, by.x = "region", by.y = "all_countries", all.x = TRUE)

color_scale <- scale_fill_gradient(low = "#FEE5D9", high = "#A50F15")

#Creating World Map for figure 3.3
ggplot(data = df_map) + geom_polygon(mapping = aes(long, lat, group = group, fill = count_part)) 
+ scale_fill_gradient(low = "#FEE5D9", high = "#A50F15", guide = "legend") + labs(fill = "Atheletes") + theme_map() 
+ color_scale + theme(plot.title = element_text(hjust = 0.5)) + ggtitle("Number of Atheletes Per Country")

#Ingesting Raw GDP data set 
gdp_raw <- read.csv("gdp.csv")

#Creating GDP dataset for last decade
gdp_last_dec <- gdp_raw[gdp_raw$Year %in% c(2000,2004,2008,2012,2016,2020), c("Country.Name", "Year", "Value")]
gdp_last_dec_top_10 <- gdp_last_dec[gdp_last_dec$Country.Name %in% c(top_10$countries),]
colnames(gdp_last_dec_top_10) <- c("Country", "Year", "Value")

#Merging the GDP dataset with medal data set
gdp_medal_merge <- merge(country_medal_df, gdp_last_dec_top_10, by.x ="countries", by.y = "Country")

medal_data_aus <- top_10_medals[top_10_medals$Team == "Australia",c("Team","Medal","Year")]
medal_data_aus_dec <- medal_data_aus[medal_data_aus$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_aus <- numeric(6)
dec_years <- c(2000,2004,2008,2012,2016,2020)
for(a in 1:6){
  count_aus[a] <- nrow(medal_data_aus_dec[medal_data_aus_dec$Year == dec_years[a],])
}

#Counting number of medals each country won
medal_data_fran <- top_10_medals[top_10_medals$Team == "France",c("Team","Medal","Year")]
medal_data_fran_dec <- medal_data_fran[medal_data_fran$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_fran <- numeric(6)
for(b in 1:6){
  count_fran[b] <- nrow(medal_data_fran_dec[medal_data_fran_dec$Year == dec_years[b],])
}

medal_data_ger <- top_10_medals[top_10_medals$Team == "Germany",c("Team","Medal","Year")]
medal_data_ger_dec <- medal_data_ger[medal_data_ger$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_ger <- numeric(6)
for(c in 1:6){
  count_ger[c] <- nrow(medal_data_ger_dec[medal_data_ger_dec$Year == dec_years[c],])
}

medal_data_hun <- top_10_medals[top_10_medals$Team == "Hungary",c("Team","Medal","Year")]
medal_data_hun_dec <- medal_data_hun[medal_data_hun$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_hun <- numeric(6)
for(d in 1:6){
  count_hun[d] <- nrow(medal_data_hun_dec[medal_data_hun_dec$Year == dec_years[d],])
}

medal_data_ita <- top_10_medals[top_10_medals$Team == "Italy",c("Team","Medal","Year")]
medal_data_ita_dec <- medal_data_ita[medal_data_ita$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_ita <- numeric(6)
for(e in 1:6){
  count_ita[e] <- nrow(medal_data_ita_dec[medal_data_ita_dec$Year == dec_years[e],])
}

medal_data_swe <- top_10_medals[top_10_medals$Team == "Sweden",c("Team","Medal","Year")]
medal_data_swe_dec <- medal_data_swe[medal_data_swe$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_swe <- numeric(6)
for(f in 1:6){
  count_swe[f] <- nrow(medal_data_swe_dec[medal_data_swe_dec$Year == dec_years[f],])
}

medal_data_usa <- top_10_medals[top_10_medals$Team == "United States",c("Team","Medal","Year")]
medal_data_usa_dec <- medal_data_usa[medal_data_usa$Year %in% c(2000,2004,2008,2012,2016,2020),]

count_usa <- numeric(6)
for(g in 1:6){
  count_usa[g] <- nrow(medal_data_usa_dec[medal_data_usa_dec$Year == dec_years[g],])
}

country_aus <- rep("Australia", times = 6)
country_fran <- rep("France", times = 6)
country_ger <- rep("Germany", times = 6)
country_hun <- rep("Hungary", times = 6)
country_ita <- rep("Italy", times = 6)
country_swe <- rep("Sweden", times = 6)
country_usa <- rep("United States", times = 6)

#Creating table columns for each country
count_year_aus <- data.frame(dec_years, rep("Australia", times = 6),count_aus)
colnames(count_year_aus) <- c("Year", "Country", "count")
count_year_fran <- data.frame(dec_years,rep("France", times = 6),count_fran)
colnames(count_year_fran) <- c("Year", "Country", "count")

count_year_ger <- data.frame(dec_years,rep("Germany", times = 6),count_ger)
colnames(count_year_ger) <- c("Year", "Country", "count")

count_year_hun <- data.frame(dec_years,rep("Hungary", times = 6),count_hun)
colnames(count_year_hun) <- c("Year", "Country", "count")

count_year_ita <- data.frame(dec_years,rep("Italy", times = 6),count_ita)
colnames(count_year_ita) <- c("Year", "Country", "count")

count_year_swe <- data.frame(dec_years,rep("Sweden", times = 6),count_swe)
colnames(count_year_swe) <- c("Year", "Country", "count")

count_year_usa <- data.frame(dec_years,rep("United States", times = 6),count_usa)
colnames(count_year_usa) <- c("Year", "Country", "count")

#Combining merged data set with all table columns
combined_df <- rbind(count_year_aus, count_year_fran, count_year_ger, count_year_hun, count_year_ita, count_year_swe, count_year_usa)

#Creating GDP vs Number of medals plot from figure 3.5
gdp_plot <- merge(combined_df,gdp_last_dec_top_10, by.x = c("Year", "Country"), by.y = c("Year", "Country"))
options(scipen = 999)
ggplot(gdp_plot, aes(x = Value, y = count)) + geom_point() 
+ labs(x = "GDP from 2000 - 2020 in USD", y = "Number of Medals") 
+ theme(plot.margin = unit(c(1, 1, 2, 1), "lines"),axis.title.x = element_text(margin = margin(t = 10)), plot.title = element_text(hjust = 0.5)) 
+ ggtitle("GDP vs Number of Medals")