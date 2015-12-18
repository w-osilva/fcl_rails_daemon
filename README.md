# FclRailsDaemon

Esta gem foi desenvolvida com a partir da necessidade de gerenciamento através do terminal em processos que por sua vez
executam determinados programas escritos em ruby.

## Instalação

A partir do Gemfile

```ruby
gem 'fcl_rails_daemon'
```

Então execute:

    $ bundle

Ou somente instale:

    $ gem install fcl_rails_daemon


## Configuração

Após a instalação é necessário criar os diretórios e arquivos de configuração, para isso execute

    $ fcld --configure

Serão criados:

 * _config/fcld_rails_daemon.rb_ (Arquivo onde são registrados os comandos)
 * _tmp/pids/fcld.yml (Arquivo onde_ são registrados os pids dos comandos)
 * _lib/fcld_comandos/comando_exemplo.rb_ (Um modelo para criação de comandos)


## Como Usar?

#### Podemos adicionar comandos através do parametro --create

    $ fcld --create meu_primeiro_comando

 * Cria um comando em lib/fcld_comandos
 * Efetua o registro em config/fcl_rails_daemon.rb


#### Podemos consultar o manual para descobrir quais os comandos disponíveis através do parametro --help

     $ fcld --help


#### Podemos consultar os pids de processos gerenciados pelo daemon através do parametro --pids

     $ fcld --pids


#### Podemos executar as ações básicas de um daemon (parametros start | stop | restart | status)

     $ fcld start


#### Podemos controlar processos individualnmente através do parametro --task

     $ fcld --task meu_primeiro_comando start

