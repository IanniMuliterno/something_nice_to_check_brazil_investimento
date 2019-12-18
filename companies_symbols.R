#push all the companies symbols

library(tidyverse)
library(rvest)
library(glue)

url <- "https://br.advfn.com/bolsa-de-valores/bovespa/"

result = data.frame(empresa = character(), simbolo = character())

for(letter in c(LETTERS)){
  
  html <- read_html(glue(url,letter))
  
  page_table <- html %>% html_node("table") %>% html_table()
  colnames(page_table) <- c("empresa", "simbolo")
  page_table$empresa <- toupper(page_table$empresa)
  
  result <- rbind(result, page_table)

}

companies_symbols <- function(){
  return (result)
}
