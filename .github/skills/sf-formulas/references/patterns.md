# Biblioteca de Padroes de Formulas Salesforce

## 1) Campo obrigatorio quando outro campo tem valor

```txt
AND(
  ISPICKVAL(Tipo__c, "Cliente"),
  ISBLANK(Documento__c)
)
```

## 2) MultiSelect obrigatorio (pelo menos uma opcao)

```txt
NOT(OR(
  INCLUDES(Tipos__c, "Cliente"),
  INCLUDES(Tipos__c, "Fornecedor"),
  INCLUDES(Tipos__c, "Patrocinador"),
  INCLUDES(Tipos__c, "Orgao Publico")
))
```

## 3) Restricao de combinacao invalida de MultiSelect

```txt
AND(
  INCLUDES(Tipos__c, "Orgao Publico"),
  NOT(OR(
    INCLUDES(Tipos__c, "Cliente"),
    INCLUDES(Tipos__c, "Fornecedor")
  ))
)
```

## 4) Bloquear edicao apos data limite

```txt
TODAY() > Data_Limite__c
```

## 5) Impedir data no passado

```txt
Data_Evento__c < TODAY()
```

## 6) Validar tamanho minimo de texto util

```txt
LEN(TRIM(Descricao__c)) < 10
```

## 7) Validar padrao com REGEX (exemplo simples de documento)

```txt
NOT(REGEX(Documento__c, "^[0-9]{11}$|^[0-9]{14}$"))
```

## 8) Formula Field Text para rotulo de status

```txt
CASE(
  TEXT(Status__c),
  "Novo", "Aguardando triagem",
  "Em_Analise", "Em analise",
  "Fechado", "Concluido",
  "Indefinido"
)
```

## 9) Formula Field Number com fallback

```txt
IF(
  ISBLANK(Valor_Contrato__c),
  0,
  Valor_Contrato__c * 0.1
)
```

## 10) Formula de prioridade por data e flag

```txt
IF(
  AND(Urgente__c, Data_Evento__c <= TODAY() + 7),
  "Alta",
  IF(Data_Evento__c <= TODAY() + 30, "Media", "Baixa")
)
```

## 11) Formula de consistencia entre campos

```txt
AND(
  NOT(ISBLANK(Data_Inicio__c)),
  NOT(ISBLANK(Data_Fim__c)),
  Data_Fim__c < Data_Inicio__c
)
```

## 12) Formula cross-object com guarda de null

```txt
AND(
  NOT(ISBLANK(Account__c)),
  Account__r.Bloqueada__c
)
```

## Padrao de escrita recomendado

1. Quebrar formula longa em multiplas linhas.
2. Agrupar por bloco logico (`AND`/`OR`).
3. Evitar duplicar condicoes repetidas; extrair helper formula field quando necessario.
4. Mensagem de erro orientada a acao para usuario final.
