# Download Manager

<p align="center" display="inline-block">
  <img src="https://img.shields.io/github/languages/top/ozmartins/downloadmanager" alt="top-language"/>  
  <img alt="Repository size" src="https://img.shields.io/github/repo-size/ozmartins/downloadmanager.svg">
  <a href="https://github.com/ozmartins/downloadmanager/commits/main">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/ozmartins/downloadmanager.svg">
  </a>
  <a href="https://github.com/ozmartins/downloadmanager">
    <img alt="Repository issues" src="https://img.shields.io/github/issues/ozmartins/downloadmanager.svg">
  </a>
  <img alt="GitHub" src="https://img.shields.io/github/license/ozmartins/downloadmanager.svg">
  </p>
</p>

# Sobre este projeto
Esta aplicação possui uma GUI que permite ao usuário realizar downloads a partir de uma URL. A aplicação possui, ainda, uma opção que permite abortar o download e uma grade que mostra o histórico de downloads.

![Screenshot_12](https://user-images.githubusercontent.com/50338986/162771056-c62b28a5-b897-4104-9146-8d0f318ad639.png)

## Tecnologias
A aplicação foi desenvolvida com Delphi e SQLite. Nenhum framework externo foi utilizado.

 - [Delphi](https://www.embarcadero.com/products/delphi)
 - [SQLite](https://sqlite.org/index.html)

## Executando a aplicação
- O executável do projeto de testes pode ser encontrado dentro de “DownloadManager\DownloadManager.Test\Win32\Debug”

- O executável da GUI pode ser encontrado dentro de “DownloadManager\DownloadManager.Vcl\Win32\Debug”

IMPORTANTE: O banco de dados precisar estar dentro do mesmo diretório do executável. O nome do arquivo do banco deve ser igual ao nome do arquivo executável da GUI. Em implementações futuras, uma opção de configuração será criada.

## Documentação
A aplicação teve seus métodos documentados dentro do próprio código fonte usando o recurso de XML Documentation do Delphi. Uma documentação externa ainda não está disponível.

## Problemas conhecidos
- Ao salvar o log do primeiro download, uma exceção do tipo "access violation" ocorre.
- Eventualmente, um erro de “access violation” ocorre após a rotina de download assíncrono emitir uma exceção (o problema não ocorre com a versão síncrona da rotina).
- A grade que exibe o log não consegue mostrar as datas de início e fim do downnload, apesar de ambas as datas estarem devidamente salvas no banco de dados.

## Implementações futuras
- Pausa de downloads.
- Múltiplos downloads simultâneos.
- Configuração do banco de dados da aplicação.
- Aumentar cobertura de testes.
- Melhorar classe TlogDownloadRepository.
- Usar ORM para persistência.
- Usar framework de mock nos testes unitários.
- Implementar um CLI (command-line interface)
- Ampliar documentação dos métodos
