library(tidyverse)
library(here)

reclamacoes_raw = read_csv(here("data/0-reclamacoes-raw/20180604-reclamacoes-raw.csv"))

reclamacoes = reclamacoes_raw %>% 
    mutate(
        nome_orgao_site = orgao,
        orgao = str_split(link, "/") %>% map_chr(~ .[[5]])
    ) %>% 
    filter(orgao %in% c("inss-ministerio-da-previdencia-social", 
                        "anac-agencia-nacional-de-aviacao-civil")) %>% 
    mutate(id = 1:n(), 
           grupo_avaliando = id %% 6 + 1)

reclamacoes %>% 
    write_csv(here("data/1-reclamacoes-selecionadas/20180605-reclamacoes-selecionadas.csv"))
