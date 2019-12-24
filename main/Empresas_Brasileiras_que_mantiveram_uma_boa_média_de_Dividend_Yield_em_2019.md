---
title: "Empresas Brasileiras que mantiveram uma boa média de Dividend Yield em 2019"
author: "Edson Henrique Delavia"
date: "23/12/2019"
output: 
  html_document:
    keep_md: true

---

\  
\  

### **Introdução**
\  
\  

#### Esse ano eu estive pensando em começar a comprar ações e estava realizando alguns estudos pra começar a entrar nesse mercado. Tenho noção de como operar, mas queria formular algumas estratégias. Ponderei muito e decidi, inicialmente, em começar com uma carteira de ações com um bom pagamento de dividendos. Mas, para isso, é preciso tempo para se avaliar as empresas e eu tenho que balancear meu tempo com outras diversas coisas que eu tenho que estudar, tanto no ambito profissional quanto no pessoal.
\  
\    
\  

#### Complicado...
\  
\  
\   

#### Eu realmente não queria postegar tanto essa tarefa, além disso, já tinha me compromissado para hoje praticar um pouco mais de Web Scrapping e explorar mais a bibloteca [tidyquant](https://business-science.github.io/tidyquant/), então, tive a brilhante ideia: vou juntar tudo e fazer uma pequena análise sobre as empresas que mantiveram uma boa média no seu dividend yield em 2019.
\  
\  

#### É uma análise bacana, mas, obviamente, não vou formular minhas hipoteses com base neste estudo. Até porque, não tenho ideia se avaliar somente isso é o ideal para tomar alguma decisão. Sou leigo no assunto, para minhas decisões pessoais vou usar ferramentas mais robustas.
\  
\  

### **Sobre a análise**
\  
\ 

#### A analise irá mostrar as top 10 empresas com maiores dividend yield (quanto de dividendo que uma empresa paga por real de ação). Há empresas que pagam mensalmente, bimestralmente, semestralmente... Então irei quebrar a análise com base nos nichos de pagamento: 12 meses, 6 meses, 3 meses, 2 meses e 1 mês.
\  
\

#### Como o foco aqui é a análise, todos os códigos usados em paralelo para extração das informações vão ficar no repositório. Então, não estranhe alguns **source()** por ai.
\  
\  

#### Sem mais delongas, vamos à análise.
\  
\  



### **Carregando pacotes necessários**

```r
source("main/utilities/necessary_packages.R")
source("main/utilities/load_libraries.R")
```
\  
\  

### **Buscando quais os tickers das empresas que vamos puxar as informações**
\  

#### Detalhe importante aqui, estou puxando todos os tickers da [advfn](https://br.advfn.com/), nem todos esses tickers são válidos, alguns devem ser bem antigos. Após isso, como a biblioteca [tidyquant](https://business-science.github.io/tidyquant/) puxa as informações do [Yahoo Finance](https://br.financas.yahoo.com/), acrescentei um **.SA** no final dos tickers. Isso porque vi que procurando os tickers lá, todos tinham esse final **.SA**.
\  


```r
source("main/utilities/companies_symbols.R")
head(companies_symbols)
```

```
##                           empresa   simbolo
## 1                  ADVANCED-DH ON  ADHM3.SA
## 2                  AES TIETE E PN  TIET4.SA
## 3                  AES TIETE E ON  TIET3.SA
## 4                   AFLUENTE T ON  AFLT3.SA
## 5 AGRO INDUSTRIAL DE CEREA... PNA AGVE5L.SA
## 6 AGRO INDUSTRIAL DE CEREA... PNB AGVE6L.SA
```

### **Extraindo dados históricos das ações e dos dividendos**
\  

#### Essa extração puxa os dados de 2019 para todas as empresas acima, as que não forem encontradas, claro, ficarão de fora. São duas extrações "demoradas" e depois é feito um join entre elas. Então o código deve demorar pelo menos uns 5 minutos para executar.
\  


```r
source("main/utilities/historical_data.R")
head(historical_data)
```

```
## # A tibble: 6 x 10
##   symbol date        open  high   low close volume adjusted value dividends
##   <chr>  <date>     <dbl> <dbl> <dbl> <dbl>  <dbl>    <dbl> <dbl>     <dbl>
## 1 ADHM3… 2019-01-02  1.49  1.5   1.49  1.5    1800     1.5     NA        NA
## 2 ADHM3… 2019-01-03  1.48  1.48  1.42  1.42   7600     1.42    NA        NA
## 3 ADHM3… 2019-01-04  1.47  1.49  1.42  1.42   1600     1.42    NA        NA
## 4 ADHM3… 2019-01-07  1.41  1.45  1.4   1.4    4500     1.4     NA        NA
## 5 ADHM3… 2019-01-08  1.4   1.4   1.39  1.39   9000     1.39    NA        NA
## 6 ADHM3… 2019-01-09  1.46  1.46  1.39  1.39   5100     1.39    NA        NA
```

### **Consolidando informações**
\

#### Com os dados em mãos, agora vamos abrir aqui um pouco de código. A ideia é agrupar o valor médio da ação e do dividendo no mês. Como não há empresas que pagam dividendos diários, a média do mês será o próprio valor do dividendo. Após isso, calculamos o <mark>dividend_yield</mark> e criamos mais um campo <mark>dividend_was_payed</mark> para contar, depois, quantas vezes a empresa pagou dividendos no ano.
\  


```r
stock_prices <-
  historical_data %>%
  select(symbol, date, adjusted, dividends) %>%
  mutate(agg_date = format(as.Date(date), "%Y-%m")) %>%
  group_by(symbol, agg_date) %>%
  summarise(month_mean_price = mean(adjusted, na.rm = TRUE), dividends = mean(dividends, na.rm = TRUE), dividend_yield = dividends/month_mean_price) %>%
  mutate(dividend_was_payed = ifelse(!(is.na(dividend_yield)), 1, 0))

head(stock_prices)
```

```
## # A tibble: 6 x 6
## # Groups:   symbol [1]
##   symbol agg_date month_mean_price dividends dividend_yield
##   <chr>  <chr>               <dbl>     <dbl>          <dbl>
## 1 AALR3… 2019-01              13.8  NaN           NaN      
## 2 AALR3… 2019-02              15.6  NaN           NaN      
## 3 AALR3… 2019-03              15.4  NaN           NaN      
## 4 AALR3… 2019-04              14.6    0.0568        0.00388
## 5 AALR3… 2019-05              14.6  NaN           NaN      
## 6 AALR3… 2019-06              13.7  NaN           NaN      
## # … with 1 more variable: dividend_was_payed <dbl>
```



```r
company_groups <- 
  stock_prices %>% 
  group_by(symbol) %>%
  summarise(periodicity = 12/sum(dividend_was_payed)) %>%
  filter(periodicity %in% c(12, 6, 3, 2, 1)) %>%
  arrange(desc(periodicity))


head(company_groups, n = 10)
```

```
## # A tibble: 10 x 2
##    symbol   periodicity
##    <chr>          <dbl>
##  1 AALR3.SA          12
##  2 ABEV3.SA          12
##  3 AFLT3.SA          12
##  4 AGRO3.SA          12
##  5 ALUP3.SA          12
##  6 ALUP4.SA          12
##  7 ANIM3.SA          12
##  8 BAUH3.SA          12
##  9 BAUH4.SA          12
## 10 BAZA3.SA          12
```


```r
avg_yield_by_periodicity <- function(p) {
  
   stock_prices %>%
   filter(symbol %in% c(company_groups %>% filter(periodicity == 12/p) %>% select(symbol) %>% distinct())$symbol ) %>%
   group_by(symbol) %>%
   summarise(period_avg_yield = mean(dividend_yield, na.rm = TRUE)) %>%
   filter(!is.na(period_avg_yield)) %>%
   arrange(desc(period_avg_yield)) %>% 
   head(10)

}
```



# Ranking por periodicidade de pagamento {.tabset .tabset-fade .tabset-pills} 

## Mensalmente


```r
avg_yield_by_periodicity(1)
```

```
## # A tibble: 10 x 2
##    symbol   period_avg_yield
##    <chr>               <dbl>
##  1 SOND6.SA           0.304 
##  2 SOND3.SA           0.198 
##  3 ENAT3.SA           0.153 
##  4 WHRL4.SA           0.106 
##  5 WHRL3.SA           0.101 
##  6 CEBR5.SA           0.101 
##  7 BAUH3.SA           0.0954
##  8 BMEB4.SA           0.0938
##  9 BMIN4.SA           0.0743
## 10 CESP5.SA           0.0739
```

## Bimestralmente


```r
avg_yield_by_periodicity(2)
```

```
## # A tibble: 10 x 2
##    symbol    period_avg_yield
##    <chr>                <dbl>
##  1 GSHP3.SA            1.05  
##  2 MMAQ4.SA            0.888 
##  3 LUXM3.SA            0.135 
##  4 CGAS5.SA            0.0719
##  5 ENMA3B.SA           0.0630
##  6 BRDT3.SA            0.0613
##  7 CGAS3.SA            0.0609
##  8 PEAB3.SA            0.0548
##  9 BRKM5.SA            0.0516
## 10 BRKM3.SA            0.0514
```


## Trimestralmente


```r
avg_yield_by_periodicity(3)
```

```
## # A tibble: 0 x 2
## # … with 2 variables: symbol <chr>, period_avg_yield <dbl>
```


## Semestralmente


```r
avg_yield_by_periodicity(6)
```

```
## # A tibble: 3 x 2
##   symbol   period_avg_yield
##   <chr>               <dbl>
## 1 ITSA4.SA          0.00977
## 2 ITSA3.SA          0.00900
## 3 HGTX3.SA          0.00572
```


## Anualmente


```r
avg_yield_by_periodicity(12)
```

```
## # A tibble: 6 x 2
##   symbol   period_avg_yield
##   <chr>               <dbl>
## 1 BEES3.SA         0.00405 
## 2 BEES4.SA         0.00399 
## 3 ITUB3.SA         0.00182 
## 4 BBDC4.SA         0.00160 
## 5 ITUB4.SA         0.00157 
## 6 BBDC3.SA         0.000715
```

