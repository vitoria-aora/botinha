@isTest
private class ContactTriggerHandlerTest {
  private static Account parentAccount() {
    Account a = new Account(Name = 'Parent Acc', Tipos_de_Conta__c = 'Cliente');
    insert a;
    return a;
  }

  @isTest
  static void insert_normalizesAllPhoneFields() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account parent = parentAccount();
    Contact c = new Contact(
      LastName = 'Silva',
      AccountId = parent.Id,
      Phone = '(21) 3333-4444',
      MobilePhone = '(21) 98881-5471',
      HomePhone = '21 3333-5555',
      OtherPhone = '988815471',
      AssistantPhone = '+14155551234'
    );
    Test.startTest();
    insert c;
    Test.stopTest();

    Contact saved = [
      SELECT Phone, MobilePhone, HomePhone, OtherPhone, AssistantPhone
      FROM Contact
      WHERE Id = :c.Id
    ];
    System.assertEquals('+552133334444', saved.Phone);
    System.assertEquals('+5521988815471', saved.MobilePhone);
    System.assertEquals('+552133335555', saved.HomePhone);
    System.assertEquals('+5521988815471', saved.OtherPhone);
    System.assertEquals('+14155551234', saved.AssistantPhone);
  }

  @isTest
  static void insert_invalidPhone_blocksDml() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account parent = parentAccount();
    Contact c = new Contact(
      LastName = 'Silva',
      AccountId = parent.Id,
      Phone = 'lixo'
    );
    try {
      insert c;
      System.assert(false, 'expected DmlException');
    } catch (DmlException e) {
      System.assert(e.getMessage().contains('não reconhecido'));
    }
  }

  @isTest
  static void update_unchangedPhone_isNotRevisited() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account parent = parentAccount();
    Contact c = new Contact(
      LastName = 'Silva',
      AccountId = parent.Id,
      Phone = '+5521988815471'
    );
    insert c;

    c.LastName = 'Silva Renamed';
    update c;
    System.assertEquals(
      '+5521988815471',
      [SELECT Phone FROM Contact WHERE Id = :c.Id].Phone
    );
  }

  @isTest
  static void update_changedPhone_normalizes() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account parent = parentAccount();
    Contact c = new Contact(
      LastName = 'Silva',
      AccountId = parent.Id,
      Phone = '+5521988815471'
    );
    insert c;

    c.Phone = '11 99999-8888';
    update c;
    System.assertEquals(
      '+5511999998888',
      [SELECT Phone FROM Contact WHERE Id = :c.Id].Phone
    );
  }

  @isTest
  static void bulk200_succeedsUnderGovernorLimits() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account parent = parentAccount();
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 200; i++) {
      contacts.add(
        new Contact(
          LastName = 'C' + i,
          AccountId = parent.Id,
          MobilePhone = '(21) 9888' + String.valueOf(10000 + i)
        )
      );
    }
    Test.startTest();
    insert contacts;
    Test.stopTest();

    Integer normalized = [
      SELECT COUNT()
      FROM Contact
      WHERE MobilePhone LIKE '+5521988%' AND AccountId = :parent.Id
    ];
    System.assertEquals(200, normalized);
  }

  @isTest
  static void personAccountContact_isSkipped() {
    List<RecordType> personRTs = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND IsPersonType = TRUE AND IsActive = TRUE
      LIMIT 1
    ];
    if (personRTs.isEmpty())
      return;

    PhoneStandardizerContext.setCachedDDD('21');
    Account pa = new Account(
      FirstName = 'Maria',
      LastName = 'Lima',
      RecordTypeId = personRTs[0].Id,
      PersonMobilePhone = '(21) 98881-5471',
      Tipos_de_Conta__c = 'Cliente'
    );
    insert pa;

    Contact paContact = [
      SELECT Id, IsPersonAccount, MobilePhone
      FROM Contact
      WHERE AccountId = :pa.Id
      LIMIT 1
    ];
    System.assertEquals(
      true,
      paContact.IsPersonAccount,
      'should be a person account contact'
    );
    System.assertEquals(
      '+5521988815471',
      paContact.MobilePhone,
      'normalized via Account trigger, not Contact trigger'
    );
  }
}
