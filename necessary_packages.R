#this code install all necessary packages from the necessary_packages.txt

pckgs <- suppressWarnings(read.delim(paste(getwd(), "/necessary_packages.txt", sep = ""), header = FALSE, stringsAsFactors = FALSE)[,1])

install.packages(pckgs)


                    
                    