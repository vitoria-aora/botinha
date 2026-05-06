---
name: sf-formulas
description: "Use when: creating, reviewing, or debugging Salesforce formulas in Validation Rules, Formula Fields, Flow formulas, and Process criteria. Covers syntax, function compatibility by field type, picklist and multiselect rules, date/math/text patterns, null handling, and anti-patterns that break deploy."
argument-hint: "Descreva o tipo de formula, objeto/campo envolvido e regra de negocio"
---

# Salesforce Formulas

Skill especialista para escrever formulas Salesforce corretas na primeira tentativa.

Escopo:

- Validation Rules (`<errorConditionFormula>`)
- Formula Fields (`<formula>`)
- Flow formulas e condition expressions
- Criterios formula-based em automacoes

Fora de escopo:

- package.xml, deploy/retrieve, scripts CLI
- modelagem de metadata XML completa (use `sf-metadata-xml`)

## Processo Obrigatorio

1. Identifique o contexto: Validation Rule, Formula Field, Flow ou Criterio.
2. Identifique o tipo de cada campo usado: Text, Number, Date, DateTime, Picklist, MultiselectPicklist, Checkbox, Currency, Percent, Lookup.
3. Consulte compatibilidade de funcoes por tipo em `references/function-compatibility.md`.
4. Monte a formula com minimo de conversoes (`TEXT`, `VALUE`, `DATEVALUE`, `DATETIMEVALUE`).
5. Rode checklist anti-erro antes de finalizar.

## Regras Criticas

### 1) MultiselectPicklist tem funcoes restritas

Para MultiselectPicklist, use apenas:

- `INCLUDES(field, "Valor")`
- `EXCLUDES(field, "Valor")`

Nao usar em MultiselectPicklist:

- `ISBLANK(field)`
- `TEXT(field)`
- `LEN(field)`
- `ISNULL(field)`

Padrao de obrigatoriedade para MultiSelect:

```txt
NOT(OR(
  INCLUDES(Tipos__c, "Valor1"),
  INCLUDES(Tipos__c, "Valor2"),
  INCLUDES(Tipos__c, "Valor3")
))
```

### 2) Picklist simples exige ISPICKVAL ou TEXT

Padroes corretos:

- `ISPICKVAL(Status__c, "Ativo")`
- `TEXT(Status__c) = "Ativo"`

Evite comparar picklist direto com `=` sem conversao.

### 3) Null e blank nao sao a mesma coisa

- Text: prefira `ISBLANK(Texto__c)`
- Number/Currency/Percent: prefira `ISBLANK(Numero__c)`
- Legacy: `ISNULL` somente quando necessario por comportamento antigo

### 4) Date vs DateTime exige conversao explicita

- DateTime -> Date: `DATEVALUE(DataHora__c)`
- Date -> DateTime: `DATETIMEVALUE(TextoDateTime)` quando realmente necessario

### 5) CROSS-OBJECT com seguranca

Antes de acessar relacao (`Conta__r.Campo__c`), valide se o lookup existe quando relevante:

```txt
AND(
  NOT(ISBLANK(Conta__c)),
  Conta__r.Ativa__c
)
```

### 6) Case sensitivity e acentos

Comparacoes textuais sao sensiveis a variacoes de escrita do dado.
Para robustez, normalize quando fizer sentido:

```txt
UPPER(TRIM(Texto__c)) = "CLIENTE"
```

## Padroes Prontos

Ver `references/patterns.md` para biblioteca de formulas prontas.

Padroes incluidos:

- Campo obrigatorio condicional
- Dependencia entre campos
- Janela de datas
- Bloqueio por perfil/role
- Regra para Picklist e MultiSelect
- Higiene de texto (trim, tamanho minimo)
- Flags financeiras basicas

## Anti-Patterns (Nao Fazer)

- Usar `ISBLANK`, `TEXT`, `LEN` em MultiselectPicklist
- Misturar Date com DateTime sem conversao
- Encadear muitos `IF` quando `CASE` resolve melhor
- Duplicar a mesma subexpressao em varios pontos
- Formula gigante sem quebrar em helper formula fields quando apropriado

## Checklist Pre-Deploy de Formula

- Tipo de todos os campos mapeado
- Funcoes validadas por tipo
- Sem funcoes proibidas para MultiSelect
- Conversoes Date/DateTime explicitas
- Mensagem de erro em portugues claro (para Validation Rule)
- Sem dependencia circular entre formula fields
- Sem hardcode desnecessario de IDs

## Diagnostico Rapido de Erros

- Erro "campo de lista de selecao multipla...": revisar regra 1
- Erro de tipo em operador matematico: conferir `VALUE()` e tipo numerico
- Erro de compilacao em data: conferir `DATEVALUE`/`DATETIMEVALUE`
- Erro de picklist: substituir comparacao por `ISPICKVAL` ou `TEXT`

## Referencias

- `references/function-compatibility.md`
- `references/patterns.md`
