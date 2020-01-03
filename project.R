library(dplyr)
library(ggplot2)
library(reshape2)
setwd("C:/Users/grzeg/Desktop/studia/Data Science/2 rok/semestr 1/Advanced_VisualisationR/projekt/Adv_Vis_R_Project")
'17th_data' <- readxl::read_xlsx("17th_joined_file.xlsx")
'18th_data' <- readxl::read_xlsx("18th_joined_file.xlsx")
'19th_data' <- readxl::read_xlsx("19th_joined_file.xlsx")
'20th_data' <- readxl::read_xlsx("20th_joined_file.xlsx")

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

