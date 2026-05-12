/**
 * Trigger Handler framework.
 *
 * Baseado em sfdc-trigger-framework de Kevin O'Hara (MIT).
 * https://github.com/kevinohara80/sfdc-trigger-framework
 */
public virtual class TriggerHandler {
  private static Map<String, LoopCount> loopCountMap = new Map<String, LoopCount>();
  private static Set<String> bypassedHandlers = new Set<String>();

  @TestVisible
  private TriggerContext context;
  @TestVisible
  private Boolean isTriggerExecuting;

  public TriggerHandler() {
    this.setTriggerContext();
  }

  public void run() {
    if (!validateRun())
      return;
    addToLoopCount();

    switch on this.context {
      when BEFORE_INSERT {
        this.beforeInsert();
      }
      when BEFORE_UPDATE {
        this.beforeUpdate();
      }
      when BEFORE_DELETE {
        this.beforeDelete();
      }
      when AFTER_INSERT {
        this.afterInsert();
      }
      when AFTER_UPDATE {
        this.afterUpdate();
      }
      when AFTER_DELETE {
        this.afterDelete();
      }
      when AFTER_UNDELETE {
        this.afterUndelete();
      }
    }
  }

  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if (!loopCountMap.containsKey(handlerName)) {
      loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  public static void bypass(String handlerName) {
    bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    bypassedHandlers.clear();
  }

  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(String ctx, Boolean testMode) {
    if (!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    }
    this.isTriggerExecuting = true;

    if (
      (Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
      (ctx == 'before insert')
    ) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if (
      (Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
      (ctx == 'before update')
    ) {
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if (
      (Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
      (ctx == 'before delete')
    ) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if (
      (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
      (ctx == 'after insert')
    ) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if (
      (Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
      (ctx == 'after update')
    ) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if (
      (Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
      (ctx == 'after delete')
    ) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if (
      (Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
      (ctx == 'after undelete')
    ) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

  @TestVisible
  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if (loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = loopCountMap.get(handlerName).increment();
      if (exceeded) {
        Integer max = loopCountMap.get(handlerName).getMax();
        throw new TriggerHandlerException(
          'Maximum loop count of ' + max + ' reached in ' + handlerName
        );
      }
    }
  }

  @TestVisible
  private Boolean validateRun() {
    if (!this.isTriggerExecuting || this.context == null) {
      throw new TriggerHandlerException(
        'Trigger handler called outside of Trigger execution'
      );
    }
    return !bypassedHandlers.contains(getHandlerName());
  }

  @TestVisible
  private String getHandlerName() {
    String self = String.valueOf(this);
    return self.substring(0, self.indexOf(':'));
  }

  @TestVisible
  protected virtual void beforeInsert() {
  }
  @TestVisible
  protected virtual void beforeUpdate() {
  }
  @TestVisible
  protected virtual void beforeDelete() {
  }
  @TestVisible
  protected virtual void afterInsert() {
  }
  @TestVisible
  protected virtual void afterUpdate() {
  }
  @TestVisible
  protected virtual void afterDelete() {
  }
  @TestVisible
  protected virtual void afterUndelete() {
  }

  @TestVisible
  private class LoopCount {
    private Integer max;
    private Integer count;
    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }
    public Boolean increment() {
      this.count++;
      return this.max >= 0 && this.count > this.max;
    }
    public Integer getMax() {
      return this.max;
    }
    public void setMax(Integer max) {
      this.max = max;
    }
  }

  public enum TriggerContext {
    BEFORE_INSERT,
    BEFORE_UPDATE,
    BEFORE_DELETE,
    AFTER_INSERT,
    AFTER_UPDATE,
    AFTER_DELETE,
    AFTER_UNDELETE
  }

  public class TriggerHandlerException extends Exception {
  }
}
