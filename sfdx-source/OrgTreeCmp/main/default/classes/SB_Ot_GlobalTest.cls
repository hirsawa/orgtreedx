@isTest
private class SB_Ot_GlobalTest {

  @isTest
  static void test_getNamespacePrefix_x() {
    String ns = SB_Ot_Global.getNamespacePrefix();
    String nsx = SB_Ot_Global.getNamespacePrefix_x();
    List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name='SB_Ot_Global'];
    if (classes.isEmpty()) {
      System.assert(String.isBlank(ns));
      System.assert(String.isBlank(nsx));
    }
    else {
      System.assert(String.isNotBlank(ns));
      System.assert((nsx.endsWith('__')));
    }
  }

  @isTest
  static void test_isEnableSmartVisca() {
    System.assertEquals(SB_Ot_Global.getNameCardSObjectType() != null, SB_Ot_Global.isEnableSmartVisca());
  }

  @isTest
  static void test_isEnableLeadExtension() {
    Map<string, Schema.SObjectField> leadFieldMap = Lead.getSObjectType().getDescribe().fields.getMap();
    System.assertEquals(leadFieldMap.containsKey('smartviscal__namecard__c'), SB_Ot_Global.isEnableLeadExtension());
  }

  @isTest
  static void test_SmartVisca() {
    System.assertEquals(SB_Ot_Global.isEnableSmartVisca(), SB_Ot_Global.getNameCardSObjectType() != null);
  }

  @isTest
  static void test_isEnablePersonAccount() {
    Boolean enabelPerson = Account.getSObjectType().getDescribe().fields.getMap().containsKey('IsPersonAccount');
    System.assertEquals(enabelPerson, SB_Ot_Global.isEnablePersonAccount());
  }

  @isTest
  static void test_TreeGridColumns_null() {
    // カスタム設定のデフォルト値をクリア
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.AccountOrgField__c = null;
    config.LeadOrgField__c = null;
    config.NameCardOrgField__c = null;
    config.AccountTreeGridColumns__c = null;
    config.ContactTreeGridColumns__c = null;
    config.LeadTreeGridColumns__c = null;
    config.NameCardTreeGridColumns__c = null;
    insert config;

    // Id だけは必須で入る。
    System.assertEquals('Name', SB_Ot_Global.otConfig.AccountOrgField__c);
    System.assertEquals('Company', SB_Ot_Global.otConfig.LeadOrgField__c);
    System.assertEquals('SmartViscaf__company_name__c', SB_Ot_Global.otConfig.NameCardOrgField__c);
    System.assertEquals('Id', SB_Ot_Global.otConfig.AccountTreeGridColumns__c);
    System.assertEquals('Id', SB_Ot_Global.otConfig.ContactTreeGridColumns__c);
    System.assertEquals('Id', SB_Ot_Global.otConfig.LeadTreeGridColumns__c);
    System.assertEquals('Id', SB_Ot_Global.otConfig.NameCardTreeGridColumns__c);
  }
}