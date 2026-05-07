---
name: sf-metadata-xml
description: "Use when: creating or editing Salesforce metadata XML files (*-meta.xml), writing Role, CustomField, ValidationRule, PermissionSet, Layout, Application, SharingRules, CompactLayout, ListView, Flow, FlexiPage, CustomObject, CustomTab, Profile metadata. Also use when diagnosing errors like 'Element invalid at this location' or 'Error parsing file'. Covers SFDX source format, element ordering rules, naming conventions, and correct field names per Metadata API. Does NOT cover package.xml, deploy or retrieve commands."
argument-hint: "Descreva o tipo de metadado e o que precisa criar ou corrigir"
---

# Salesforce Metadata XML

Regras e templates para escrever arquivos `*-meta.xml` corretos no formato SFDX. Escopo: **escrita do arquivo**. Deploy, retrieve e package.xml estão fora do escopo desta skill.

## Regras Críticas

### 1. Elementos em ordem alfabética

A Metadata API exige que os elementos filho de cada tag estejam em **ordem alfabética**. Violação causa `Element X invalid at this location`.

**Errado:**

```xml
<Role>
  <name>CEO</name>
  <caseAccessLevel>Edit</caseAccessLevel>  <!-- 'c' antes de 'n' → erro -->
</Role>
```

**Correto:**

```xml
<Role>
  <caseAccessLevel>Edit</caseAccessLevel>
  <name>CEO</name>
</Role>
```

### 2. Nomes de elementos são case-sensitive e específicos por tipo

- `Role` → `<name>` (não `<label>`)
- `CustomField` → `<label>` (não `<name>`)
- `ValidationRule` → `<errorConditionFormula>` (não `<formula>`)
- `CustomApplication` → `<label>` para o nome de exibição

### 3. Inclua apenas elementos suportados pelo tipo

Elementos inválidos para o tipo causam parse error mesmo estando em ordem correta.

### 4. Namespace obrigatório na tag raiz

```xml
<?xml version="1.0" encoding="UTF-8"?>
<TipoMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
```

### 5. Acentos: use UTF-8 direto

Não escapar acentos — arquivo deve ser salvo em UTF-8. Escapar apenas `<`, `>`, `&` dentro de fórmulas e atributos: `&lt;`, `&gt;`, `&amp;`.

### 6. `<fullName>` é obrigatório em CustomField quando deployado via manifest

Quando o deploy usa `--manifest package.xml` (não `--source-dir`), o Salesforce exige `<fullName>` dentro do XML de cada campo. Sem ele, o erro é `element fullName missing for a child of type CustomField`.

**Obrigatório:** `<fullName>` deve ser o **primeiro** elemento filho (antes de `<label>`, `<externalId>`, etc.) para manter ordem alfabética.

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Nome_Do_Campo__c</fullName>
    <label>Nome do Campo</label>
    ...
</CustomField>
```

> Boa prática: **sempre incluir `<fullName>`** em todo CustomField, independente do modo de deploy.

### 7. Funções de fórmula suportadas por tipo de campo

O Salesforce restringe quais funções podem referenciar campos `MultiselectPicklist` em ValidationRules.

**Funções SUPORTADAS para MultiselectPicklist:**

- `INCLUDES(Campo__c, "Valor")`
- `EXCLUDES(Campo__c, "Valor")`

**Funções NÃO suportadas para MultiselectPicklist:**

- `ISBLANK(Campo__c)` → erro `campo é lista de seleção múltipla, só suportado em determinadas funções`
- `TEXT(Campo__c)` → mesma restrição
- `LEN(Campo__c)` → mesma restrição
- `ISNULL(Campo__c)` → mesma restrição

**Padrão correto para "campo obrigatório" em MultiSelectPicklist:**

```xml
<errorConditionFormula>NOT(OR(
    INCLUDES(Tipos__c, "Valor1"),
    INCLUDES(Tipos__c, "Valor2"),
    INCLUDES(Tipos__c, "Valor3")
))</errorConditionFormula>
```

Isso dispara o erro quando **nenhum** valor está selecionado — equivalente semântico ao `ISBLANK()`.

---

## Convenção de Nomes de Arquivo SFDX

| Tipo                     | Sufixo do arquivo          | Pasta                               |
| ------------------------ | -------------------------- | ----------------------------------- |
| Role                     | `.role-meta.xml`           | `roles/`                            |
| CustomField              | `.field-meta.xml`          | `objects/<Object>/fields/`          |
| ValidationRule           | `.validationRule-meta.xml` | `objects/<Object>/validationRules/` |
| CustomObject             | `.object-meta.xml`         | `objects/<Object>/`                 |
| CompactLayout            | `.compactLayout-meta.xml`  | `objects/<Object>/compactLayouts/`  |
| ListView                 | `.listView-meta.xml`       | `objects/<Object>/listViews/`       |
| RecordType               | `.recordType-meta.xml`     | `objects/<Object>/recordTypes/`     |
| Layout                   | `.layout-meta.xml`         | `layouts/`                          |
| PermissionSet            | `.permissionset-meta.xml`  | `permissionsets/`                   |
| Profile                  | `.profile-meta.xml`        | `profiles/`                         |
| CustomApplication        | `.app-meta.xml`            | `applications/`                     |
| FlexiPage                | `.flexipage-meta.xml`      | `flexipages/`                       |
| Flow                     | `.flow-meta.xml`           | `flows/`                            |
| CustomTab                | `.tab-meta.xml`            | `tabs/`                             |
| SharingRules             | `.sharingRules-meta.xml`   | `sharingRules/`                     |
| StaticResource           | `.resource-meta.xml`       | `staticresources/`                  |
| LightningComponentBundle | `<name>.js-meta.xml`       | `lwc/<name>/`                       |

---

## Templates por Tipo

Ver [`./references/templates.md`](./references/templates.md) para templates completos dos tipos:

**Objetos e Campos:** Role, CustomObject, CustomField (Text / Picklist / MultiSelectPicklist / Checkbox / Number / Lookup), ValidationRule, CompactLayout, ListView, RecordType

**Segurança:** PermissionSet, Profile (trecho), SharingRules

**UI:** CustomApplication, FlexiPage, Layout, CustomTab

**Automação:** Flow (Screen Flow, Record-Triggered Flow)

**LWC:** js-meta.xml

---

## Diagnóstico de Erros de Parse

| Erro                                                                      | Causa                                                                            | Correção                                                   |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `Element X invalid at this location (N:M)`                                | Elemento fora de ordem ou nome errado                                            | Reordenar alfabeticamente; checar nome exato               |
| `Error parsing file`                                                      | XML malformado ou elemento inexistente no tipo                                   | Comparar com template; remover elemento extra              |
| `Required field is missing: fullName`                                     | `<fullName>` ausente no XML do campo                                             | Adicionar como **primeiro** elemento filho                 |
| `Invalid fullName`                                                        | Caractere inválido                                                               | Só letras, números, underscore; inicia com letra           |
| `campo é lista de seleção múltipla. só suportado em determinadas funções` | Uso de `ISBLANK()`, `TEXT()` ou `LEN()` em fórmula com campo MultiselectPicklist | Substituir por `NOT(OR(INCLUDES(...), ...))` — ver Regra 7 |

---

## Referências

- [Metadata API — lista de tipos](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_types_list.htm)
- [Role](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_role.htm)
- [CustomField](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_customfield.htm)
- [ValidationRule](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_validationrule.htm)
- [PermissionSet](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_permissionset.htm)
- [CustomApplication](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_lightningapp.htm)
- [FlexiPage](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_flexipage.htm)
- [Flow](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_visual_workflow.htm)
