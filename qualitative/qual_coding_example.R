# Basic qualitative coding using the quanteda package
library(quanteda)

text <- c("Participants reported feeling safer after the intervention.",
          "Some noted improvements in local infrastructure.")

corpus_obj <- corpus(text)
tokens_obj <- tokens(corpus_obj, remove_punct = TRUE)
dfm_obj <- dfm(tokens_obj)

print(dfm_obj)