library(tidyverse)
library(rvest)
library(stringr)

buscas = c(
    "https://cidadao.reclameaqui.com.br/busca/?cx=008144464031947637647%3A7airzwxfigw&cof=FORID%3A10&ie=UTF-8&q=minist%C3%A9rio&id=&BuscaTipo=E", 
    "https://cidadao.reclameaqui.com.br/busca/?cx=008144464031947637647%3A7airzwxfigw&cof=FORID%3A10&ie=UTF-8&q=ag%C3%AAncia+nacional&id=&BuscaTipo=E", 
    "https://cidadao.reclameaqui.com.br/busca/?cx=008144464031947637647%3A7airzwxfigw&cof=FORID%3A10&ie=UTF-8&q=federal&id=&BuscaTipo=E"
)

busca2listas = function(url_busca){
    lista_html = read_html(url_busca) %>% 
        html_nodes("#box_resultado ul li") 
    
    lista_html %>%  
        map_df(~ tibble(orgao = html_text(.), 
                        link = html_nodes(., "a")[[2]] %>% html_attr('href'))) %>% 
        return()
}

# lista de orgaos com links para as listas de reclamacoes
links_orgaos = buscas %>% 
    map(busca2listas) %>% 
    bind_rows() %>% 
    filter(grepl("- BR", orgao, fixed = F)) %>% 
    mutate(orgao = str_extract(orgao, "(?<=\\n)(.*)(?=- BR\\t)") %>% str_trim())

# salva a lista dos orgaos usados
links_orgaos %>%  
    write_csv("data/reclamacoes-raw/links-listas-orgaos.csv")

# listas de reclamacoes
reclamacoes = links_orgaos %>% 
    pmap( ~ {read_html(.y) %>% 
                html_nodes("#lista_reclamacoes td a") %>% 
                html_attr('href')})

#
# AMOSTRAGEM
# 

# Dentre os órgãos com pelo menos 20 reclamações, 
# escolheremos 20. De cada um, pegamos 20 reclamações.
set.seed(123)

selecionados = reclamacoes %>% 
    discard(~ NROW(.) < 23) %>%  # temos 3 links que não são reclamações
    sample(20)


amostra_reclamacoes <- function(d){
    r = d[grepl("reclameaqui", d) & !grepl("lista_reclamacoes|indices", d)]
    if(length(r) < 20){
        return(c())
    }
    return(sample(r, 20))
}

rec_df = selecionados %>% 
    map_df(~ tibble(orgao = .[!grepl(".com", .) & grepl(".br", .)][1], 
                    link = list(amostra_reclamacoes(.)))) %>% 
    filter(!map_lgl(link, is.null)) %>% 
    unnest(link) 

# Agora pegamos o texto de cada reclamação
pega_textos = function(link){
    read_html(link) %>% 
        html_nodes("section p") %>% 
        map(html_text)
}

rec_completo = rec_df %>% 
    group_by(link) %>% 
    mutate(titulo = possibly(pega_textos, "erro")(link)[3],
           reclamacao = possibly(pega_textos, "erro")(link)[4])

# Várias reclamações da PGR dão erro na recuperação, então descartaremos 
# esse órgão

rec_completo %>% 
    filter(is.na(orgao) | orgao != "http://www.pgr.mpf.mp.br/") %>% 
    unnest(titulo, reclamacao) %>% 
    write_csv("data/reclamacoes-raw/reclamacoes-raw.csv")

