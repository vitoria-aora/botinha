# CLAUDE.md — botinha

Herda `Projects/CLAUDE.md` e `Projects/salesforce/CLAUDE.md`.

## Modo

mode: developer

## Projeto

Salesforce DX — desenvolvimento solo contra sandbox. Stack:

- **Apex** — `force-app/main/default/classes`, `triggers`
- **LWC** — `force-app/main/default/lwc/*/`
- **Metadata** — `force-app/main/default/{objects,permissionsets,flows,layouts,...}`

## Org

| Alias         | URL                                                                  | Uso            |
| ------------- | -------------------------------------------------------------------- | -------------- |
| `botinha-sbx` | https://newstageentretenimento--aoradev.sandbox.lightning.force.com/ | sandbox de dev |

Org padrão local: `botinha-sbx` (declarado em `.sf/config.json` e `.sf-org`).

Nunca commitar `.sf/`, `.sfdx/` ou qualquer token.

## Lifecycle de feature por chat

A cada chat novo, o fluxo padrão se aplica (ver `_shared/docs/FEATURE_LIFECYCLE.md`):

1. Claude pergunta: _"Qual o nome do chat?"_
2. Nome informado → cria branch git `<slug>`, pasta `branches/<slug>/` com `package.xml` próprio, anota slug em `.active-feature`.
3. Todos os comandos `/sf-*` usam `branches/<slug>/package.xml` + `botinha-sbx` como org.
4. Sem scratch org (somente sandbox) — Fase 4 do lifecycle é pulada.
5. Encerrar com `/sf-feature-close` ao término da feature.

`branches/` e `.active-feature` são gitignored — não commitar.

## Convenções de metadata

- PascalCase para Apex classes, triggers, objetos
- `__c` para custom objects/fields
- Trigger handler: `<Object>TriggerHandler`
- Test class: `<ClassName>Test`
- Permission sets > profiles

## Não mexer

- `.sfdx/`, `.sf/` — caches locais (gitignored)
- `branches/` — pastas de feature (gitignored)
