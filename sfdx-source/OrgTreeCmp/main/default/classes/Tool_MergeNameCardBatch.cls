public with sharing class Tool_MergeNameCardBatch  implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

  String query;
  private class CardUnit{
    public Id recordId { get; private set; }
    public String name { get; private set; }
    public String division { get; private set; }
    public String title { get; private set; }
    public String email { get; private set; }
    public Date exchangeDate { get; private set; }
    public CardUnit(SmartViscaf__NameCard__c card) {
        this.recordId = card.Id;
        this.name = card.Name;
        this.division = card.SmartViscaf__division__c;
        this.title = card.SmartViscaf__title_name__c;
        this.email = card.SmartViscaf__email__c;
        this.exchangeDate = card.SmartViscaf__card_exchange_date__c;
    }
    public Boolean isSameUnit(SmartViscaf__NameCard__c card) {
      return this.email == card.SmartViscaf__email__c && this.name == card.Name;
    }
  }

  private CardUnit lastUnit;

  private static String QUERY_FORMAT = 'SELECT Id, Name, SmartViscaf__Parent__c, SmartViscaf__company_name__c, SmartViscaf__division_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c, SmartViscaf__email__c, SmartViscaf__card_exchange_date__c FROM SmartViscaf__NameCard__c {0} ORDER BY SmartViscaf__email__c ASC, SmartViscaf__card_exchange_date__c DESC NULLS LAST';

  public Tool_MergeNameCardBatch(String condition) {
    String whereEx = String.isNotBlank(condition) ? ' WHERE ' + condition : '';
    this.query = String.format(QUERY_FORMAT, new String[] { whereEx });
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug(this.query);
    return Database.getQueryLocator(this.query);
  }

  public void execute(Database.BatchableContext BC, List<SmartViscaf__NameCard__c> scope) {
    System.debug('execute scioe size: ' + scope.size());
    for (SmartViscaf__NameCard__c card : scope) {
      if (this.lastUnit != null && this.lastUnit.isSameUnit(card)) {
        card.SmartViscaf__Parent__c = this.lastUnit.recordId;
        continue;
      }
      else {
        this.lastUnit = new CardUnit(card);
        card.SmartViscaf__Parent__c = null;
        continue;
      }
    }
    update scope;
  }

  public void finish(Database.BatchableContext BC) {

  }
  // スケジュール用メソッド
  public void execute(SchedulableContext sc) {
    Id batchProcessId = Database.executeBatch(this);
  }

}