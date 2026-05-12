@isTest
private class AccountTriggerHandlerTest {
  private static Account buildBusiness(String name, String phone, String fax) {
    return new Account(
      Name = name,
      Phone = phone,
      Fax = fax,
      Tipos_de_Conta__c = 'Cliente'
    );
  }

  @isTest
  static void insert_normalizesPhoneAndFax() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '(21) 98881-5471', '(21) 3333-4444');
    Test.startTest();
    insert a;
    Test.stopTest();

    Account saved = [SELECT Phone, Fax FROM Account WHERE Id = :a.Id];
    System.assertEquals('+5521988815471', saved.Phone);
    System.assertEquals('+552133334444', saved.Fax);
  }

  @isTest
  static void insert_alreadyCanonical_isIdempotent() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '+5521988815471', null);
    insert a;
    Account saved = [SELECT Phone FROM Account WHERE Id = :a.Id];
    System.assertEquals('+5521988815471', saved.Phone);
  }

  @isTest
  static void insert_invalidPhone_blocksDml() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', 'fone do joão', null);
    try {
      insert a;
      System.assert(false, 'expected DmlException');
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('não reconhecido'),
        'expected validation error, got: ' + e.getMessage()
      );
    }
  }

  @isTest
  static void update_changedPhone_normalizes() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '+5521988815471', null);
    insert a;

    a.Phone = '(11) 99999-8888';
    update a;
    System.assertEquals(
      '+5511999998888',
      [SELECT Phone FROM Account WHERE Id = :a.Id].Phone
    );
  }

  @isTest
  static void update_unchangedPhone_isNotRevisited() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '+5521988815471', null);
    insert a;

    a.Name = 'ACME Renamed';
    update a;
    System.assertEquals(
      '+5521988815471',
      [SELECT Phone FROM Account WHERE Id = :a.Id].Phone
    );
  }

  @isTest
  static void update_invalidPhone_blocks() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '+5521988815471', null);
    insert a;
    a.Phone = 'lixo';
    try {
      update a;
      System.assert(false, 'expected DmlException');
    } catch (DmlException e) {
      System.assert(e.getMessage().contains('não reconhecido'));
    }
  }

  @isTest
  static void update_clearingPhoneToNull_isAllowed() {
    PhoneStandardizerContext.setCachedDDD('21');
    Account a = buildBusiness('ACME', '+5521988815471', null);
    insert a;
    a.Phone = null;
    update a;
    System.assertEquals(
      null,
      [SELECT Phone FROM Account WHERE Id = :a.Id].Phone
    );
  }

  @isTest
  static void bulk200_succeedsUnderGovernorLimits() {
    PhoneStandardizerContext.setCachedDDD('21');
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
      accounts.add(
        buildBusiness(
          'Bulk Acc ' + i,
          '(21) 9888' + String.valueOf(10000 + i),
          '21 3333-' + (4000 + i)
        )
      );
    }
    Test.startTest();
    insert accounts;
    Test.stopTest();

    Integer normalized = [
      SELECT COUNT()
      FROM Account
      WHERE Phone LIKE '+5521%' AND Name LIKE 'Bulk Acc%'
    ];
    System.assertEquals(200, normalized);
  }

  @isTest
  static void personAccount_normalizesPersonFields() {
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
      FirstName = 'Joao',
      LastName = 'Silva',
      RecordTypeId = personRTs[0].Id,
      PersonMobilePhone = '(21) 98881-5471',
      PersonHomePhone = '(21) 3333-4444',
      Tipos_de_Conta__c = 'Cliente'
    );
    insert pa;

    Account saved = [
      SELECT PersonMobilePhone, PersonHomePhone
      FROM Account
      WHERE Id = :pa.Id
    ];
    System.assertEquals('+5521988815471', saved.PersonMobilePhone);
    System.assertEquals('+552133334444', saved.PersonHomePhone);
  }
}
