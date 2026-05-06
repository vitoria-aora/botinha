# Botinha - Salesforce DX (Sandbox)

Projeto Salesforce configurado para desenvolvimento com sandbox.

## Ambiente Atual

- Projeto local: `C:\Users\vitoria\Projects\salesforce\botinha`
- Repositorio remoto: `https://github.com/vitoria-aora/botinha.git`
- Org padrao local (target-org): `botinha-sbx`
- URL da sandbox: `https://newstageentretenimento--aoradev.sandbox.lightning.force.com/`

## Setup Rapido

1. Instale dependencias:

   ```bash
   npm install
   ```

2. Confirme org padrao:

   ```bash
   sf config get target-org
   sf org list
   ```

3. Abra a org:

   ```bash
   sf org open
   ```

## Fluxo de Trabalho (Sandbox First)

1. Atualize a branch principal local:

   ```bash
   git checkout main
   git pull origin main
   ```

2. Crie uma branch de feature:

   ```bash
   git checkout -b feature/nome-da-feature
   ```

3. Traga metadados da sandbox (quando necessario):

   ```bash
   sf project retrieve start --manifest manifest/package.xml
   ```

4. Implemente mudancas no `force-app`.

5. Faça deploy para sandbox:

   ```bash
   sf project deploy start --source-dir force-app
   ```

6. Rode testes Apex (recomendado antes de subir PR):

   ```bash
   sf apex run test --test-level RunLocalTests
   ```

7. Commit e push:

   ```bash
   git add .
   git commit -m "feat: descricao da entrega"
   git push -u origin feature/nome-da-feature
   ```

8. Abra Pull Request para `main`.

## Comandos NPM uteis

Veja os scripts no `package.json` para comandos rapidos de org, retrieve, deploy e validacao.

```bash
npm run org:open
npm run sf:retrieve
npm run sf:deploy
npm run sf:deploy:check
npm run sf:test:apex
```

## Boas Praticas

- Sempre trabalhar em branch de feature.
- Evitar deploy de tudo sem necessidade em ambientes compartilhados.
- Priorizar deploy seletivo quando estiver com mais de um time atuando na mesma sandbox.
- Rodar testes locais antes de abrir PR.
- Manter `manifest/package.xml` atualizado para facilitar retrieve/deploy por escopo.

## Referencias

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
