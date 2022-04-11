# Download Manager
Esta aplicação possui uma GUI que permite ao usuário realizar downloads a partir de uma URL. A aplicação possui, ainda, uma opção que permite abortar o download e uma grade que mostra o histórico de downloads.

![Screenshot_12](https://user-images.githubusercontent.com/50338986/162768192-c03e1c93-0f41-4b7e-8551-e73f858ac321.png)

## Tecnologias
A aplicação foi desenvolvida com Delphi e SQLite. Nenhum framework externo foi utilizado.

 - [Delphi](https://www.embarcadero.com/products/delphi)
 - [SQLite](https://sqlite.org/index.html)

## Executando a aplicação
- O executável do projeto de testes pode ser encontrado dentro de “DownloadManager\DownloadManager.Test\Win32\Debug”

- O executável da GUI pode ser encontrado dentro de “DownloadManager\DownloadManager.Vcl\Win32\Debug”

IMPORTANTE: O banco de dados precisar estar dentro do mesmo diretório do executável. O nome do arquivo do banco deve ser igual ao nome do arquivo executável da GUI. Em eventuais implementações, uma opção de configuração será criada.

## Documentação
A aplicação teve seus métodos documentados dentro do próprio código fonte usando o recurso de XML Documentation do Delphi. Uma documentação externa ainda não está disponível.

## Problemas conhecidos
- Ao salvar o log do primeiro download, uma exceção do tipo "access violation" ocorre.
- Eventualmente, um erro de “access violation” ocorre após a rotina de download assíncrono emitir uma exceção (o problema não ocorre com a versão síncrona da rotina).

## Implementações futuras
- Pausa de downloads.
- Múltiplos downloads simultâneos.
- Configuração do banco de dados da aplicação.
- Aumentar cobertura de testes.
- Melhor classe TlogDownloadRepository.
- Usar ORM para persistência.
- Usar framework de mock nos testes unitários.
- Implementar um CLI (command-line interface)
