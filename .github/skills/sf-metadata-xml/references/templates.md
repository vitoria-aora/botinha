# Templates de Metadata XML — Salesforce

Todos os templates seguem ordem alfabética de elementos (obrigatório pela Metadata API).

---

## Role

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Role xmlns="http://soap.sforce.com/2006/04/metadata">
    <caseAccessLevel>Edit</caseAccessLevel>
    <contactAccessLevel>Edit</contactAccessLevel>
    <description>Descrição opcional</description>
    <mayForecastManagerShare>false</mayForecastManagerShare>
    <name>NomeDaRole</name>
    <opportunityAccessLevel>Edit</opportunityAccessLevel>
    <!-- parentRole: omitir se for raiz da hierarquia -->
    <parentRole>NomeDaRolePai</parentRole>
</Role>
```

**`<name>`** é o label de exibição em Role (não `<label>`).
Omitir `caseAccessLevel`/`contactAccessLevel` se Cases/Contacts não estiverem habilitados na org.

---

## CustomObject

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <actionOverrides>
        <actionName>View</actionName>
        <type>Default</type>
    </actionOverrides>
    <compactLayoutAssignment>SYSTEM</compactLayoutAssignment>
    <deploymentStatus>Deployed</deploymentStatus>
    <description>Descrição do objeto.</description>
    <label>Label Singular</label>
    <nameField>
        <label>Nome</label>
        <type>Text</type>
    </nameField>
    <pluralLabel>Label Plural</pluralLabel>
    <searchLayouts />
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
```

Para standard objects (Account, Contact), o `.object-meta.xml` normalmente contém apenas `compactLayoutAssignment` e outras sobrescritas — não redeclara o objeto inteiro.

---

## CustomField — Text

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Nome_Do_Campo__c</fullName>
    <externalId>false</externalId>
    <label>Label do Campo</label>
    <length>100</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
```

> `<fullName>` é obrigatório quando o deploy usa `--manifest`. Incluir sempre como boa prática.

---

## CustomField — Picklist (local)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Picklist</type>
    <valueSet>
        <restricted>false</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <default>true</default>
                <fullName>Valor Padrão</fullName>
                <label>Valor Padrão</label>
            </value>
            <value>
                <default>false</default>
                <fullName>Outro Valor</fullName>
                <label>Outro Valor</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

---

## CustomField — MultiSelectPicklist

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>MultiselectPicklist</type>
    <valueSet>
        <restricted>false</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <default>false</default>
                <fullName>Opção 1</fullName>
                <label>Opção 1</label>
            </value>
            <value>
                <default>false</default>
                <fullName>Opção 2</fullName>
                <label>Opção 2</label>
            </value>
        </valueSetDefinition>
    </valueSet>
    <visibleLines>4</visibleLines>
</CustomField>
```

Type é `MultiselectPicklist` (sem espaço).

---

## CustomField — Checkbox

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultValue>false</defaultValue>
    <label>Label do Campo</label>
    <trackTrending>false</trackTrending>
    <type>Checkbox</type>
</CustomField>
```

---

## CustomField — Number / Currency

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <precision>18</precision>
    <required>false</required>
    <scale>2</scale>
    <trackTrending>false</trackTrending>
    <type>Number</type>
    <unique>false</unique>
</CustomField>
```

Para moeda: `<type>Currency</type>`.

---

## CustomField — Lookup

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <deleteConstraint>SetNull</deleteConstraint>
    <label>Label do Campo</label>
    <referenceTo>ObjectoAlvo__c</referenceTo>
    <relationshipLabel>Label da Related List</relationshipLabel>
    <relationshipName>NomeDoRelacionamento</relationshipName>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Lookup</type>
</CustomField>
```

`deleteConstraint`: `SetNull` | `Restrict` | `Cascade`.

---

## ValidationRule

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <active>true</active>
    <description>Descrição da regra (opcional)</description>
    <errorConditionFormula>ISBLANK(Campo__c)</errorConditionFormula>
    <!-- errorDisplayField: omitir para exibir erro no topo do layout -->
    <errorDisplayField>Campo__c</errorDisplayField>
    <errorMessage>Mensagem de erro para o usuário.</errorMessage>
    <fullName>NomeDaRegra</fullName>
</ValidationRule>
```

**ATENÇÃO — MultiselectPicklist:** `ISBLANK()`, `TEXT()` e `LEN()` **não** funcionam com campos MultiSelectPicklist. Use `INCLUDES()` / `EXCLUDES()`.

Padrão para "campo obrigatório" em MultiSelectPicklist:

```xml
<errorConditionFormula>NOT(OR(
    INCLUDES(Campo__c, "Valor1"),
    INCLUDES(Campo__c, "Valor2"),
    INCLUDES(Campo__c, "Valor3")
))</errorConditionFormula>
```

---

## CompactLayout

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CompactLayout xmlns="http://soap.sforce.com/2006/04/metadata">
    <fields>Name</fields>
    <fields>Campo1__c</fields>
    <fields>Phone</fields>
    <label>Nome do Compact Layout</label>
</CompactLayout>
```

Arquivo em `objects/<Object>/compactLayouts/`. Para atribuir como primário, referenciar em `objects/<Object>/<Object>.object-meta.xml` via `<compactLayoutAssignment>NomeDoCompactLayout</compactLayoutAssignment>`.

---

## ListView

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<ListView xmlns="http://soap.sforce.com/2006/04/metadata">
    <columns>NAME</columns>
    <columns>PHONE</columns>
    <columns>OWNER.FULL_NAME</columns>
    <filterScope>Everything</filterScope>
    <filters>
        <field>Campo__c</field>
        <operation>includes</operation>
        <value>Valor</value>
    </filters>
    <label>Nome da List View</label>
    <language>pt_BR</language>
    <sharedTo>
        <allInternalUsers />
    </sharedTo>
</ListView>
```

`filterScope`: `Everything` | `Mine` | `MyTeam` | `Queue`.
`operation`: `equals` | `notEqual` | `includes` | `excludes` | `startsWith` | `contains`.

---

## RecordType

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<RecordType xmlns="http://soap.sforce.com/2006/04/metadata">
    <active>true</active>
    <description>Descrição do record type.</description>
    <label>Label do Record Type</label>
    <picklistValues>
        <picklist>NomeDoCampoPicklist__c</picklist>
        <values>
            <fullName>ValorDisponível</fullName>
            <default>false</default>
        </values>
    </picklistValues>
</RecordType>
```

---

## PermissionSet

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>NomeDoApp</application>
        <visible>true</visible>
    </applicationVisibilities>
    <description>Descrição do permission set.</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Object__c.Campo__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <label>Label do Permission Set</label>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Object__c</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <tabSettings>
        <tab>standard-Account</tab>
        <visibility>Available</visibility>
    </tabSettings>
</PermissionSet>
```

---

## CustomApplication (Lightning App)

Arquivo: `applications/NomeDoApp.app-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultLandingTab>standard-Account</defaultLandingTab>
    <description>Descrição do app.</description>
    <formFactors>Large</formFactors>
    <formFactors>Small</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>Nome do App</label>
    <navType>Standard</navType>
    <tabs>standard-Account</tabs>
    <tabs>standard-Contact</tabs>
    <uiType>Lightning</uiType>
</CustomApplication>
```

Tabs padrão usam prefixo `standard-`. Tabs custom usam o API name do objeto.

---

## CustomTab

Arquivo: `tabs/NomeDoObjeto__c.tab-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>
    <motif>Custom62: Globe</motif>
</CustomTab>
```

Para tab de URL externa:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>false</customObject>
    <frameHeight>600</frameHeight>
    <hasSidebar>false</hasSidebar>
    <label>Label da Tab</label>
    <motif>Custom62: Globe</motif>
    <url>https://exemplo.com</url>
    <urlEncodingKey>UTF-8</urlEncodingKey>
</CustomTab>
```

---

## FlexiPage (Lightning Page)

Arquivo: `flexipages/NomeDaPagina.flexipage-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<FlexiPage xmlns="http://soap.sforce.com/2006/04/metadata">
    <flexiPageRegions>
        <componentInstances>
            <componentInstanceProperties>
                <name>recordId</name>
                <value>{!recordId}</value>
            </componentInstanceProperties>
            <componentName>c:meuComponente</componentName>
        </componentInstances>
        <mode>Append</mode>
        <name>main</name>
        <type>Region</type>
    </flexiPageRegions>
    <masterLabel>Nome da Página</masterLabel>
    <pageTemplate>MasterDetail_A</pageTemplate>
    <sobjectType>Account</sobjectType>
    <type>RecordPage</type>
</FlexiPage>
```

`type`: `RecordPage` | `AppPage` | `HomePage` | `UtilityBar`.
`pageTemplate`: `MasterDetail_A` | `MasterDetail_B_C` | `OneColumn` | `TwoColumn_LeftSidebar` etc.

---

## Flow (Screen Flow)

Arquivo: `flows/NomeDoFlow.flow-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <description>Descrição do flow.</description>
    <interviewLabel>Nome do Flow {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Nome do Flow</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processType>Flow</processType>
    <screens>
        <allowBack>true</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>false</allowPause>
        <fields>
            <fieldType>DisplayText</fieldType>
            <name>TextoExibicao</name>
            <fieldText>Texto de exibição.</fieldText>
        </fields>
        <label>Tela Inicial</label>
        <name>Tela_Inicial</name>
        <showFooter>true</showFooter>
        <showHeader>true</showHeader>
    </screens>
    <start>
        <locationX>176</locationX>
        <locationY>48</locationY>
        <connector>
            <targetReference>Tela_Inicial</targetReference>
        </connector>
    </start>
    <status>Active</status>
</Flow>
```

---

## Flow (Record-Triggered Flow)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <description>Descrição do flow.</description>
    <interviewLabel>Nome {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Nome do Flow</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value><stringValue>LightningFlowBuilder</stringValue></value>
    </processMetadataValues>
    <processType>AutoLaunchedFlow</processType>
    <start>
        <locationX>176</locationX>
        <locationY>48</locationY>
        <object>Account</object>
        <recordTriggerType>Update</recordTriggerType>
        <triggerType>RecordAfterSave</triggerType>
    </start>
    <status>Active</status>
    <triggerOrder>1</triggerOrder>
</Flow>
```

`recordTriggerType`: `Create` | `Update` | `CreateAndUpdate` | `Delete`.
`triggerType`: `RecordBeforeSave` | `RecordAfterSave` | `RecordBeforeDelete`.

---

## LWC — js-meta.xml

Arquivo: `lwc/<nomeDoComponente>/<nomeDoComponente>.js-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Account</object>
            </objects>
            <property name="recordId" type="String" />
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

`isExposed: false` para componentes internos (não aparecem no Lightning App Builder).

---

## SharingRules (placeholder)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <!-- OWD não é configurável via Metadata API para objetos standard.
         Ajustar manualmente: Setup > Security > Sharing Settings -->
</SharingRules>
```

---

## Role

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Role xmlns="http://soap.sforce.com/2006/04/metadata">
    <caseAccessLevel>Edit</caseAccessLevel>
    <contactAccessLevel>Edit</contactAccessLevel>
    <description>Descrição opcional</description>
    <mayForecastManagerShare>false</mayForecastManagerShare>
    <name>NomeDaRole</name>
    <opportunityAccessLevel>Edit</opportunityAccessLevel>
    <!-- parentRole: omitir se for raiz da hierarquia -->
    <parentRole>NomeDaRolePai</parentRole>
</Role>
```

**Campos obrigatórios:** `mayForecastManagerShare`, `name`
**Atenção:** `<name>` é o label de exibição em Role (não `<label>`). `caseAccessLevel` e `contactAccessLevel` são da superclasse `RoleOrTerritory` — incluir somente se Cases/Contacts estiverem habilitados na org; se a org não tiver Cases, omitir `caseAccessLevel`.

---

## CustomField — Text

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <externalId>false</externalId>
    <label>Label do Campo</label>
    <length>100</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
```

---

## CustomField — Picklist (local)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Picklist</type>
    <valueSet>
        <restricted>false</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <default>true</default>
                <fullName>Valor Padrão</fullName>
                <label>Valor Padrão</label>
            </value>
            <value>
                <default>false</default>
                <fullName>Outro Valor</fullName>
                <label>Outro Valor</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

---

## CustomField — MultiSelectPicklist

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>MultiselectPicklist</type>
    <valueSet>
        <restricted>false</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <default>false</default>
                <fullName>Opção 1</fullName>
                <label>Opção 1</label>
            </value>
            <value>
                <default>false</default>
                <fullName>Opção 2</fullName>
                <label>Opção 2</label>
            </value>
        </valueSetDefinition>
    </valueSet>
    <visibleLines>4</visibleLines>
</CustomField>
```

**Atenção:** o type é `MultiselectPicklist` (sem espaço, sem hífen).

---

## CustomField — Checkbox

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultValue>false</defaultValue>
    <label>Label do Campo</label>
    <trackTrending>false</trackTrending>
    <type>Checkbox</type>
</CustomField>
```

---

## CustomField — Number / Currency

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Label do Campo</label>
    <precision>18</precision>
    <required>false</required>
    <scale>2</scale>
    <trackTrending>false</trackTrending>
    <type>Number</type>
    <!-- Para currency: <type>Currency</type> -->
    <unique>false</unique>
</CustomField>
```

---

## ValidationRule

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <active>true</active>
    <description>Descrição da regra (opcional)</description>
    <errorConditionFormula>ISBLANK(Campo__c)</errorConditionFormula>
    <errorDisplayField>Campo__c</errorDisplayField>
    <!-- errorDisplayField: omitir para exibir erro no topo do layout -->
    <errorMessage>Mensagem de erro para o usuário.</errorMessage>
    <fullName>NomeDaRegra</fullName>
</ValidationRule>
```

**Atenção:** `<fullName>` deve ser o mesmo que o nome do arquivo (sem o sufixo).

---

## PermissionSet

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>NomeDoApp</application>
        <visible>true</visible>
    </applicationVisibilities>
    <description>Descrição do permission set.</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Object__c.Campo__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <label>Label do Permission Set</label>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Object__c</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <tabSettings>
        <tab>standard-Account</tab>
        <visibility>Available</visibility>
    </tabSettings>
</PermissionSet>
```

---

## LightningApp

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<LightningExperienceTheme xmlns="http://soap.sforce.com/2006/04/metadata">
</LightningExperienceTheme>
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<AppMenu xmlns="http://soap.sforce.com/2006/04/metadata">
    <appMenuItems>
        <name>standard-Account</name>
        <position>1</position>
        <type>Tab</type>
    </appMenuItems>
</AppMenu>
```

**Use o tipo correto — Lightning App:**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<LightningExperienceTheme xmlns="http://soap.sforce.com/2006/04/metadata">
</LightningExperienceTheme>
```

Tipo correto para app no App Launcher:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<AppMenu xmlns="http://soap.sforce.com/2006/04/metadata">
```

**Atenção:** Lightning Apps usam o tipo `LightningExperienceTheme` para temas ou `CustomApplication` para apps no metadata. O arquivo `.app-meta.xml` no SFDX corresponde ao tipo `CustomApplication`:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultLandingTab>standard-Account</defaultLandingTab>
    <description>Descrição do app.</description>
    <formFactors>Large</formFactors>
    <formFactors>Small</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>Nome do App</label>
    <navType>Standard</navType>
    <tabs>standard-Account</tabs>
    <tabs>standard-Contact</tabs>
    <uiType>Lightning</uiType>
    <utilityBar />
</CustomApplication>
```

---

## SharingRules (placeholder — OWD não é configurável via API)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <!-- OWD deve ser ajustado manualmente em Setup > Security > Sharing Settings -->
</SharingRules>
```

---

## package.xml — estrutura e tipos comuns

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>NomeDoApp</members>
        <name>CustomApplication</name>
    </types>
    <types>
        <members>Account.Campo__c</members>
        <name>CustomField</name>
    </types>
    <types>
        <members>Account</members>
        <name>CustomObject</name>
    </types>
    <types>
        <members>Account.NomeDaRegra</members>
        <name>ValidationRule</name>
    </types>
    <types>
        <members>NomeDoLayout</members>
        <name>Layout</name>
    </types>
    <types>
        <members>NomeDoPS</members>
        <name>PermissionSet</name>
    </types>
    <types>
        <members>CEO</members>
        <members>Operacional</members>
        <name>Role</name>
    </types>
    <types>
        <members>Account</members>
        <name>SharingRules</name>
    </types>
    <version>66.0</version>
</Package>
```

**Regras do package.xml:**

- `<types>` em ordem alfabética pelo `<name>`
- `<members>` em ordem alfabética dentro de cada `<types>`
- Para campos/VRs de objetos: `<members>NomeObjeto.NomeCampo</members>`
- Para objetos inteiros: `<members>NomeObjeto</members>` no tipo `CustomObject`
- Suporte a wildcard `*` em muitos tipos: `<members>*</members>`
