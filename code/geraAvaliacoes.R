library(tidyverse)
library(rvest)
library(stringr)

setwd("/Users/raquelvl/Documents/GitHub/reclamacoes-do-gf")
avaliacoes <- read_csv("data/3-avaliacao-humana/avaliacoes-20180610.csv")

glimpse(avaliacoes)

avaliacoes <- avaliacoes %>% select(matricula = "Matricula", 
                                    id.reclamacao = "ID da reclamação", 
                                    avaliacao = "Grau de insatisfação")
glimpse(avaliacoes)

avaliacoes <- avaliacoes %>% select(id.reclamacao, avaliacao) %>% 
              group_by(id.reclamacao) %>% 
              summarise(insatisfacao = median(avaliacao), 
                        avaliadores = n(),
                        range.avaliacoes = (max(avaliacao) - min(avaliacao)))

#quantas avaliações tem discordancia de avaliação maior que 2? Será que devemos confiar nessas avaliações?
avaliacoes %>% filter(range.avaliacoes > 2) 

reclamacoes.avaliadas <- read_csv("data/1-reclamacoes-selecionadas/20180605-reclamacoes-selecionadas_sem-repeticao.csv")

names(reclamacoes.avaliadas)
names(avaliacoes)

reclamacoes <- left_join(reclamacoes.avaliadas, avaliacoes, 
                         by = c("id" = "id.reclamacao"))

reclamacoes %>%  write_csv("data/3-avaliacao-humana/reclamacoes-avaliadas-20180703.csv")
