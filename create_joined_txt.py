#### Tu masz kod, który Ci stworzy zbiorcze pliki na podstawie książek, które są w odpowiednich folderach. 

import os
files = {}
directory = r"C:\Users\grzeg\Desktop\studia\Data Science\2 rok\semestr 1\Advanced_VisualisationR\projekt\Adv_Vis_R_Project\books"
for cent in os.listdir(directory):
    centuries_directory = directory + "\{}".format(cent)
    file_list = [centuries_directory + "\{}".format(x) for x in os.listdir(centuries_directory)]
    files[centuries_directory] = file_list.copy()


for century_directory, file_list in files.items():
    
    if len(file_list) != 0:
        with open(century_directory + "\joined_file.txt", "w", encoding="utf8") as outfile:        
            for file in file_list:
                
                try:
                    with open(file, "r", encoding="utf8") as infile:
                        for line in infile:
                            outfile.write(line)
                except:
                    print(file)
                    with open(file, "r", encoding="utf8", errors="replace") as infile:
                        for line in infile:
                            outfile.write(line)
