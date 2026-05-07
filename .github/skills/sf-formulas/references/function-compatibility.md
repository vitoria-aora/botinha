# Compatibilidade de Funcoes por Tipo de Campo

Tabela pratica para evitar erro de compilacao antes do deploy.

## Text

Funcoes comuns:

- `ISBLANK`, `BLANKVALUE`
- `LEN`, `LEFT`, `RIGHT`, `MID`
- `TRIM`, `LOWER`, `UPPER`
- `SUBSTITUTE`, `CONTAINS`, `BEGINS`
- `REGEX`

Cuidados:

- Para comparar sem ruido de espaco/caixa: `UPPER(TRIM(campo))`

## Number / Currency / Percent

Funcoes comuns:

- `ISBLANK`, `BLANKVALUE`
- `ROUND`, `CEILING`, `FLOOR`, `ABS`
- Operadores `+ - * /`

Conversoes:

- Texto para numero: `VALUE(Texto__c)`

## Checkbox

Padrao:

- `Campo__c` (true)
- `NOT(Campo__c)` (false)

Evite:

- `Campo__c = true`

## Date

Funcoes comuns:

- `TODAY`, `DATE`, `YEAR`, `MONTH`, `DAY`
- `ADDMONTHS`

Padroes:

- Vencido: `Data__c < TODAY()`
- Em X dias: `Data__c <= TODAY() + 7`

## DateTime

Funcoes comuns:

- `NOW`
- `DATEVALUE(DataHora__c)`

Cuidados:

- Compare DateTime com Date apenas apos conversao

## Picklist (single)

Use:

- `ISPICKVAL(Status__c, "Ativo")`
- `TEXT(Status__c) = "Ativo"`

Evite:

- Comparacao direta sem conversao

## MultiselectPicklist

Use:

- `INCLUDES(Tipos__c, "Cliente")`
- `EXCLUDES(Tipos__c, "Fornecedor")`

Nao use:

- `ISBLANK(Tipos__c)`
- `TEXT(Tipos__c)`
- `LEN(Tipos__c)`
- `ISNULL(Tipos__c)`

Padrao de obrigatorio:

```txt
NOT(OR(
  INCLUDES(Tipos__c, "Cliente"),
  INCLUDES(Tipos__c, "Fornecedor"),
  INCLUDES(Tipos__c, "Patrocinador"),
  INCLUDES(Tipos__c, "Orgao Publico")
))
```

## Lookup / Master-Detail

Use:

- `ISBLANK(Lookup__c)` para verificar preenchimento
- `Lookup__r.Campo__c` para acessar campos relacionados

Cuidados:

- Verifique nulo antes de dereferenciar em cenarios sensiveis

## Formula Field Return Types

- Return Type = Text: expressoes devem resultar em string
- Return Type = Number: resultado numerico
- Return Type = Date/DateTime: usar funcoes coerentes
- Return Type = Checkbox: resultado booleano

Erro comum:

- Misturar numero e texto no mesmo `IF` sem converter
