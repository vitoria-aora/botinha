# Botinha - Salesforce DX

## Ambiente

| Item         | Valor                                                                |
| ------------ | -------------------------------------------------------------------- |
| Alias da org | `botinha-sbx`                                                        |
| Sandbox      | https://newstageentretenimento--aoradev.sandbox.lightning.force.com/ |
| Repositorio  | https://github.com/vitoria-aora/botinha.git                          |
| Modo         | `developer` (PRs direto para `main`)                                 |

## Setup inicial

```bash
npm install
sf org open        # confirma acesso à sandbox
```

## Fluxo por feature (cada chat = uma feature)

O Claude segue o lifecycle definido em `_shared/docs/FEATURE_LIFECYCLE.md`:

1. Claude pergunta o nome do chat no inicio de cada conversa.
2. Nome informado → branch git `<slug>` + pasta `branches/<slug>/package.xml` criados automaticamente.
3. Toda metadata criada/editada e adicionada ao `branches/<slug>/package.xml` incrementalmente.
4. Ao final da feature: `/sf-feature-close` — deleta branch local/remota e limpa a pasta.

`branches/` e `.active-feature` sao gitignored; nao commitar.

## Comandos NPM

```bash
npm run org:open          # abre a sandbox no browser
npm run sf:retrieve       # retrieve via manifest/package.xml
npm run sf:deploy         # deploy de force-app para a sandbox
npm run sf:deploy:check   # validacao sem deploy (RunLocalTests)
npm run sf:test:apex      # executa testes Apex locais
```

## Slash commands disponiveis

| Comando             | Acao                                              |
| ------------------- | ------------------------------------------------- |
| `/sf-deploy`        | validate + deploy para `botinha-sbx`              |
| `/sf-retrieve`      | retrieve de metadata (`/sf-retrieve ApexClass:X`) |
| `/sf-test`          | testes Apex afetados pelo diff                    |
| `/sf-scan`          | Code Analyzer nos arquivos do diff                |
| `/sf-pr`            | abre PR para `main` com resumo                    |
| `/sf-feature-close` | encerra feature ativa (checa PR, limpa branch)    |

## Referencias

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Feature Lifecycle](../salesforce/_shared/docs/FEATURE_LIFECYCLE.md)
