# Dados raspados do ReclameAqui com reclamações do Gov Federal

Dados coletados com o script `code/coleta_reclamacoes.R`. Decisões na coleta estão documentadas lá. 
`links-listas-orgaos.csv` é um dado intermediário das listas acessadas para decidir que reclamações recuperar. 

`*-reclamacoes-raw.csv` contém os órgãos, títulos e reclamações dos órgãos que amostramos, com as seguintes diferenças:

* `20171217-reclamacoes-raw.csv` foi coletado em 2017-12-17 com uma versão do script que tentava coletar 20 reclamações aleatórias dentre as 30 mais recentes (ou seja, as da 1a página de reclamações) dos órgãos selecionados. 
* `20180604-reclamacoes-raw.csv` foi coletado em 2018-06-04 com uma versão do script que coleta as 30 reclamações mais recentes (ou seja, as da 1a página de reclamações) dos órgãos selecionados. 