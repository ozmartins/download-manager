<h1 align="center">Download Manager</h1>
<p align="center"><i>Um gerenciador de download simples feito com Delphi e SQLite.</i></p>

<p align="center" display="inline-block">
  <img src="https://img.shields.io/github/languages/top/ozmartins/downloadmanager" alt="top-language"/>  
  <img alt="Repository size" src="https://img.shields.io/github/repo-size/ozmartins/downloadmanager.svg">
  <a href="https://github.com/ozmartins/downloadmanager/commits/main">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/ozmartins/downloadmanager.svg">
  </a>
  <a href="https://github.com/ozmartins/downloadmanager/issues">
    <img alt="Repository issues" src="https://img.shields.io/github/issues/ozmartins/downloadmanager.svg">
  </a>
  <img alt="GitHub" src="https://img.shields.io/github/license/ozmartins/downloadmanager.svg">
  </p>
</p>

# Sobre este projeto
Esta aplicação possui uma GUI que permite ao usuário realizar downloads a partir de uma URL. A aplicação possui, ainda, as seguintes opções:
- Abortar o download
- Visualizar o progresso do download 
- Visualizar o histórico de downloads

## Tópicos

 - [Tecnologias](#tecnologias)
 - [Dependências](#dependências)
 - [Executando a aplicação](#executando-a-aplicação)
 - [Documentação](#documentação)
 - [Problemas conhecidos e implementações futuras](#problemas-conhecidos-e-implementações-futuras)
 
## Tecnologias
A aplicação foi desenvolvida com Delphi e SQLite. Nenhum framework externo foi utilizado.

 - [Delphi](https://www.embarcadero.com/products/delphi)
 - [SQLite](https://sqlite.org/index.html)

## Dependências

Esse projeto usa o [Boss](https://github.com/HashLoad/boss) como gerenciador de dependências. Antes de tentar compilar a aplicação, baixa o Boss do seguinte endereço https://github.com/hashload/boss/releases. Em seguida, instale-o no seu computador. Depois, acesse a pasta ./download-manager/DownloadManager.Vcl e digite o seguinte comando.

```
boss install
```
O comando acima também deve ser executado dentro da pasta do projeto de testes (./download-manager/DownloadManager.Test)

## Executando a aplicação

- O executável do projeto de testes pode ser encontrado dentro de “DownloadManager\DownloadManager.Test\Win32\Debug”

- O executável da GUI pode ser encontrado dentro de “DownloadManager\DownloadManager.Vcl\Win32\Debug”

IMPORTANTE: O banco de dados precisar estar dentro do mesmo diretório do executável. O nome do arquivo do banco deve ser igual ao nome do arquivo executável da GUI.

## Documentação
A aplicação teve seus métodos documentados dentro do próprio código fonte usando o recurso de XML Documentation do Delphi. Uma documentação externa ainda não está disponível.

## Problemas conhecidos e implementações futuras
Ver página de [issues](https://github.com/ozmartins/DownloadManager/issues)
