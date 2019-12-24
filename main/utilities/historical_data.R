historical_data <- tq_get(companies_symbols$simbolo, get = "stock.prices", from = "2019-01-01", complete_cases = TRUE)

