# Post-Deploy Checklist

Passos manuais obrigatórios após cada deploy. Execute na ordem indicada.

---

## 1. Ajustar OWD de Account para Private

**Quando:** após o primeiro deploy em qualquer org (sandbox ou produção).

**Por quê:** a Metadata API não expõe OWD de objetos standard de forma confiável. Precisa ser feito manualmente.

**Passos:**

1. Acesse **Setup → Security → Sharing Settings**.
2. Clique em **Edit** na seção "Organization-Wide Defaults".
3. Localize o objeto **Account**.
4. Altere "Default Internal Access" para **Private**.
5. Clique em **Save**.

> Nota: ao tornar Account Private, o Salesforce pode exibir um aviso de recálculo de sharing. Aguarde a conclusão antes de prosseguir.

---

## 2. Ajustar OWD de Contact para Controlled by Parent

**Quando:** imediatamente após o passo 1.

**Passos:**

1. Na mesma tela **Setup → Security → Sharing Settings**.
2. Localize o objeto **Contact**.
3. Altere "Default Internal Access" para **Controlled by Parent**.
4. Clique em **Save**.

> Efeito: um Contact só é visível a quem tem acesso à Account pai. Isso garante que cada sócio vê apenas os contatos das suas próprias contas.

---

## 3. Verificar Role Hierarchy após deploy

1. Acesse **Setup → Users → Roles**.
2. Confirme a hierarquia: `Sócio Fundador` (topo) → `Sócio Operacional` (filho).
3. Atribua as roles aos usuários conforme o plano:
   - Cristiano → **Sócio Fundador**
   - Carla, Morena, Bocão, Luiz → **Sócio Operacional**

---

## 4. Atribuição do Lightning App CRM Eventos como padrão (após Atividade 9)

Após deploy do app `CRM_Eventos`:

1. **Setup → Apps → App Manager**.
2. Localize **CRM Eventos** → **Edit**.
3. Na aba **Navigation Items**, confirme Account e Contact estão na lista.
4. Se necessário, vá em **Setup → Users → Profiles** → abrir o perfil → **Assigned Apps** e marcar CRM Eventos como visível.

---

_Última atualização: 2026-05-06_
