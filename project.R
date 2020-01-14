library(dplyr)
library(ggplot2)
library(reshape2)
setwd("C:/Users/grzeg/Desktop/studia/Data Science/2 rok/semestr 1/Advanced_VisualisationR/projekt/Adv_Vis_R_Project")
'17th_data' <- readxl::read_xlsx("17th_joined_file.xlsx")
'18th_data' <- readxl::read_xlsx("18th_joined_file.xlsx")
'19th_data' <- readxl::read_xlsx("19th_joined_file.xlsx")
'20th_data' <- readxl::read_xlsx("20th_joined_file.xlsx")
authors_data <- data.frame(readxl::read_xlsx("Author_birthplace_with_geo_data.xlsx"))

## In our analysis we will focus on 4 main parts of speech -> Adjectives, Adverbs, Nouns, Verbs. Other parts of speech will be treated as the rest
authors_data %>% group_by(Century) %>% tally(name = "Number of Authors")
century_basic
century_basic_long <- melt(century_basic, id=c("centuries"))
century_basic_long
ggplot(century_basic_long) + geom_bar(aes(x = centuries, y = value, fill = variable), stat = "identity", position = "dodge", width = 0.7) + 
  scale_fill_manual("Variable\n", values = c("orange", "blue"), labels = c("Number of Titles", "Number of Authors")) + 
  ggtitle("Initial Comparison") + 
  labs(x = "\nCenturies", y = "\nNumber of") + 
  theme_bw(base_size = 14)
`17th_data`

century_basic_long <- melt(century_basic[,c("centuries", "num_of_occ", "num_of_unique")], id=c("centuries"))
century_basic_long

ggplot(century_basic_long) + geom_bar(aes(x = centuries, y = value, fill = variable), stat = "identity", position = "dodge", width = 0.7) + 
  scale_fill_manual("Variable\n", values = c("orange", "blue"), labels = c("Count of All Words", "Count of Unique Words")) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ggtitle("All Words vs Unique Words") + 
  labs(x = "\nCenturies", y = "\nNumber of") + 
  theme_bw(base_size = 14)

century_basic <- century_basic %>% mutate(Unique_to_all = round(num_of_unique/num_of_occ,4))
ggplot(century_basic) + geom_bar(aes(x = centuries, y = Unique_to_all), stat = "identity", width = 0.7, fill ="orange") + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ggtitle("Count of Unique Words to All Words") + 
  labs(x = "\nCenturies", y = "\nProportion") + 
  theme_bw(base_size = 14)

length(`17th_data`$Part_of_speech)
`17th_data`
length(`17th_data`[`17th_data`$Part_of_speech == 'Other',"Lemma"])



pie_data <- `17th_data` %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(`17th_data`$Part_of_speech) * 100,2))
pie_data <- pie_data %>% mutate(lbls = paste(Part_of_speech, Percentage, "%"))
pie(pie_data$Percentage, labels = pie_data$lbls, col = rainbow(length(pie_data$lbls)))


pie_chart <- function(df, title){
  pie_data <- df %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(df$Part_of_speech) * 100,2))
  pie_data <- pie_data %>% mutate(lbls = paste(Part_of_speech, Percentage, "%"))
  pie(pie_data$Percentage, labels = pie_data$lbls, col = rainbow(length(pie_data$lbls)), 
      main = title)
}
par(mfrow=c(2,2), oma = c(0, 0, 2, 0))
pie_chart(`17th_data`, "17th Century")
pie_chart(`18th_data`, "18th Century")
pie_chart(`19th_data`, "19th Century")
pie_chart(`20th_data`, "20th Century")
mtext("Percentage Pie Chart of Parts of Speech for Unique Words", outer = TRUE, cex = 1.5)


Part_of_speech <- cbind(centuries = c(rep(c("17th"),5), rep(c("18th"),5), rep(c("19th"),5), rep(c("20th"),5)),
  rbind(data.frame(`17th_data` %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(`17th_data`$Part_of_speech) * 100,2))),
      data.frame(`18th_data` %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(`18th_data`$Part_of_speech) * 100,2))),
      data.frame(`19th_data` %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(`19th_data`$Part_of_speech) * 100,2))),
      data.frame(`20th_data` %>% group_by(Part_of_speech) %>% summarise(Percentage = round(n()/length(`20th_data`$Part_of_speech) * 100,2)))))


ggplot(Part_of_speech, aes(x = centuries, y = Percentage, fill = Part_of_speech)) + geom_bar(stat = "identity", position = "stack", width = 0.7) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  geom_text(aes(label = paste0(Percentage,"%")), 
            position = position_stack(vjust = 0.5), size = 3) +
  labs(fill = "Part of Speech") +
  ggtitle("Parts of Speech Proportions") + 
  labs(x = "\nCenturies", y = "\nPercentage") + 
  theme_bw(base_size = 14)   


head(`17th_data`)
senti_data <- rbind(
                    data.frame(Centuries = "17th", 
                             neg = sum(`17th_data`$neg)/length(`17th_data`$neg), 
                             neu = sum(`17th_data`$neu)/length(`17th_data`$neu),
                             pos = sum(`17th_data`$pos)/length(`17th_data`$pos)),
                    data.frame(Centuries = "18th", 
                             neg = sum(`18th_data`$neg)/length(`18th_data`$neg), 
                             neu = sum(`18th_data`$neu)/length(`18th_data`$neu),
                             pos = sum(`18th_data`$pos)/length(`18th_data`$pos)),
                    data.frame(Centuries = "19th", 
                             neg = sum(`19th_data`$neg)/length(`19th_data`$neg), 
                             neu = sum(`19th_data`$neu)/length(`19th_data`$neu),
                             pos = sum(`19th_data`$pos)/length(`19th_data`$pos)),
                    data.frame(Centuries = "20th", 
                             neg = sum(`20th_data`$neg)/length(`20th_data`$neg), 
                             neu = sum(`20th_data`$neu)/length(`20th_data`$neu),
                             pos = sum(`20th_data`$pos)/length(`20th_data`$pos))
                    )

senti_data
melt(senti_data) %>% ggplot(aes(x = Centuries, y = value, fill = variable)) + geom_bar(stat = "identity", position = "stack", width = 0.7) + 
  scale_y_continuous(labels = function(x) paste0(x * 100, "%")) +
  geom_text(aes(label = paste0(round(value * 100,2),"%")), 
           position = position_stack(vjust = 0.5), size = 3) + 
  labs(fill = "Sentiment", y = "Percentage") +
  theme_bw(base_size = 14)


## dla Compound - może się przyda
avg_senti_data <- rbind(
  data.frame(Centuries = "17th", Average_Score = mean(`17th_data`$compound)),
  data.frame(Centuries = "18th", Average_Score = mean(`18th_data`$compound)),
  data.frame(Centuries = "19th", Average_Score = mean(`19th_data`$compound)),
  data.frame(Centuries = "20th", Average_Score = mean(`20th_data`$compound))
)

avg_senti_data




####################

install.packages("ggmap")
library(ggmap)
qmap(location="london")

# first - set the API key for google maps
# for details check ?register_google
# https://cloud.google.com/maps-platform/

# PFFFFFFFFFFFFFFFT
map <- get_map(location = "London", zoom = 8)


install.packages("plotly")
install.packages("maps")
library(plotly)
library(maps)

map_data("world", "canada") %>%
  group_by(group) %>%
  plot_geo(x = ~long, y = ~lat) %>%
  add_markers(size = I(1))

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoiY2ltY2lyaW1jaSIsImEiOiJjazU5ejkwZmQxMjdjM2VxeGdqOGVnMnRkIn0.ZcC-1pGUFVd80U1G0G2yoQ')
plot_mapbox(maps::canada.cities) %>%
  add_markers(
    x = ~long, 
    y = ~lat, 
    size = ~pop, 
    color = ~country.etc,
    colors = "Accent",
    text = ~paste(name, pop),
    hoverinfo = "text"
  )


df = read.csv('https://raw.githubusercontent.com/bcdunbar/datasets/master/meteorites_subset.csv')

p <- df %>%
  plot_mapbox(lat = ~reclat, lon = ~reclong,
              split = ~class, size=2,
              mode = 'scattermapbox', hoverinfo='name') %>%
  layout(title = 'Meteorites by Class',
         font = list(color='white'),
         plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
         mapbox = list(style = 'dark'),
         legend = list(orientation = 'h',
                       font = list(size = 8)),
         margin = list(l = 25, r = 25,
                       b = 25, t = 25,
                       pad = 2)) %>%
  config(mapboxAccessToken = Sys.getenv("MAPBOX_TOKEN"))

p


map_plot <- authors_data %>% 
  plot_mapbox(lon = ~longitude,
              lat = ~latitude,
              split = ~Century,
              size=2,
              mode = 'scattermapbox+markers',
              text=~paste(Author, Birthplace, sep = "\n"),
              hoverinfo='text',
              marker=list(opacity=0.67, size=15)) %>% 
  layout(title = "Birthplace of the most popular authors from 17th to 20th century",
         mapbox = list(),
         legend = list(orientation='h', y=0.12),
         margin = list(l = 25, r = 25,
                       b = 25, t = 25,
                       pad = 2)
         )

map_plot

plot_mapbox(maps::canada.cities)
plot_mapbox(maps::canada.cities) %>% 
  add_markers(
    x = authors_data$longitude,
    y = authors_data$latitude,
    text = authors_data$Author
  )

