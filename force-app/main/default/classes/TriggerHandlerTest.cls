@isTest
private class TriggerHandlerTest {
  public class FakeHandler extends TriggerHandler {
    public Map<String, Integer> calls = new Map<String, Integer>{
      'beforeInsert' => 0,
      'beforeUpdate' => 0,
      'beforeDelete' => 0,
      'afterInsert' => 0,
      'afterUpdate' => 0,
      'afterDelete' => 0,
      'afterUndelete' => 0
    };
    protected override void beforeInsert() {
      bump('beforeInsert');
    }
    protected override void beforeUpdate() {
      bump('beforeUpdate');
    }
    protected override void beforeDelete() {
      bump('beforeDelete');
    }
    protected override void afterInsert() {
      bump('afterInsert');
    }
    protected override void afterUpdate() {
      bump('afterUpdate');
    }
    protected override void afterDelete() {
      bump('afterDelete');
    }
    protected override void afterUndelete() {
      bump('afterUndelete');
    }
    private void bump(String k) {
      calls.put(k, calls.get(k) + 1);
    }
  }

  @isTest
  static void run_outsideOfTrigger_throws() {
    try {
      new FakeHandler().run();
      System.assert(
        false,
        'expected exception when run outside trigger context'
      );
    } catch (TriggerHandler.TriggerHandlerException e) {
      System.assert(e.getMessage().contains('outside of Trigger execution'));
    }
  }

  @isTest
  static void eachContext_dispatchesCorrectMethod() {
    List<String> contexts = new List<String>{
      'before insert',
      'before update',
      'before delete',
      'after insert',
      'after update',
      'after delete',
      'after undelete'
    };
    Map<String, String> expectedKey = new Map<String, String>{
      'before insert' => 'beforeInsert',
      'before update' => 'beforeUpdate',
      'before delete' => 'beforeDelete',
      'after insert' => 'afterInsert',
      'after update' => 'afterUpdate',
      'after delete' => 'afterDelete',
      'after undelete' => 'afterUndelete'
    };
    for (String ctx : contexts) {
      FakeHandler h = new FakeHandler();
      h.setTriggerContext(ctx, true);
      h.run();
      System.assertEquals(
        1,
        h.calls.get(expectedKey.get(ctx)),
        'context ' + ctx
      );
    }
  }

  @isTest
  static void bypass_skipsExecution() {
    FakeHandler h = new FakeHandler();
    h.setTriggerContext('before insert', true);
    TriggerHandler.bypass('FakeHandler');
    System.assertEquals(true, TriggerHandler.isBypassed('FakeHandler'));
    h.run();
    System.assertEquals(0, h.calls.get('beforeInsert'));
    TriggerHandler.clearBypass('FakeHandler');
    h.run();
    System.assertEquals(1, h.calls.get('beforeInsert'));
  }

  @isTest
  static void clearAllBypasses_resetsAll() {
    TriggerHandler.bypass('A');
    TriggerHandler.bypass('B');
    TriggerHandler.clearAllBypasses();
    System.assertEquals(false, TriggerHandler.isBypassed('A'));
    System.assertEquals(false, TriggerHandler.isBypassed('B'));
  }

  @isTest
  static void loopCount_exceedsMax_throws() {
    FakeHandler h = new FakeHandler();
    h.setTriggerContext('before insert', true);
    h.setMaxLoopCount(2);
    h.run();
    h.run();
    try {
      h.run();
      System.assert(false, 'expected loop count exception');
    } catch (TriggerHandler.TriggerHandlerException e) {
      System.assert(e.getMessage().contains('Maximum loop count'));
    }
  }

  @isTest
  static void clearMaxLoopCount_removesLimit() {
    FakeHandler h = new FakeHandler();
    h.setTriggerContext('before insert', true);
    h.setMaxLoopCount(1);
    h.run();
    h.clearMaxLoopCount();
    h.run();
    h.run();
    System.assertEquals(3, h.calls.get('beforeInsert'));
  }
}
