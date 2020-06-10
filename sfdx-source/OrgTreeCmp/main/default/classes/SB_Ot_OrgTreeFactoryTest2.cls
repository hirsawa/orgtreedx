/**
 *
 *  SB_Ot_OrgTreeFactoryTest2
 *    SB_Ot_OrgTreeFactory のテストクラス  アカウント、コンタクト の階層ノード作成 のテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0      2019.03.xx
 *
 */
@isTest
private class SB_Ot_OrgTreeFactoryTest2 {

  private static List<Account> createChildAccount(List<Account> parents) {
    List<Account> result = new List<Account>();
    for (Account parent : parents) {
      result.add(new Account(Name=parent.Name+'01', ParentId=parent.Id));
      result.add(new Account(Name=parent.Name+'02', ParentId=parent.Id));
    }
    insert result;
    return result;
  }

  private static List<Contact> createContacts(List<Account> acnts) {
    List<Contact> result = new List<Contact>();
    for (Account acnt : acnts) {
      result.add(new Contact(LastName=acnt.Name+'社員01', FirstName='太郎', Department='開発部 開発課', Title='課長', Email='taro@' + acnt.Id + '.com',
            AccountId=acnt.Id, MailingPostalCode='150-0022', MailingState='東京都', MailingCity='渋谷区', MailingStreet='恵比寿南1-5-5'));
      result.add(new Contact(LastName=acnt.Name+'社員02', FirstName='次郎', Department='営業部 営業課', Title='課長', Email='jiro@' + acnt.Id + '.com',
            AccountId=acnt.Id, MailingPostalCode='150-0022', MailingState='東京都', MailingCity='渋谷区', MailingStreet='恵比寿南1-5-5'));
    }
    insert result;
    return result;
  }

  @TestSetup
  static void setupAccountsContacs() {
    List<Account> acnts = new List<Account>();
    List<Contact> conts;
    acnts.add(new Account(Name='エンタ株式会社'));  // 1
    insert acnts;
    conts = createContacts(acnts);      // 2
    acnts = createChildAccount(acnts);      // 1+2
    conts = createContacts(acnts);      // 2+4
    acnts = createChildAccount(acnts);      // 3+4
    conts = createContacts(acnts);      // 6+8

    // カスタム設定を初期化
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.PrioritizeCustomSetting__c = true;  // カスタム設定を優先する
    config.AccountAssociation__c = true;      // 取引先 親・子の取引先を階層に含める#
    config.ContactTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail, MailingAddress, OwnerId';
    config.AccountOtherCondition__c = 0;
    config.ContactOtherCondition__c = 0;
    config.LeadOtherCondition__c = 0;
    config.UserOtherCondition__c = 0;
    insert config;
  }

  @isTest
  static void test_createOrgTreeItems_by_Account() {
    Account rootAcnt = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE ParentId != null];
    // List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgTreeItems(acnts[0].Id, Account.getSObjectType());
    SB_Ot_OrgTreeItem.TreeItem root = (SB_Ot_OrgTreeItem.TreeItem)items[0];
    root.print();
    System.assert(root.label.startsWith(rootAcnt.Name));
  }

  @isTest
  static void test_createOrgGridItems_by_Account() {
    Account rootAcnt = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
    List<Account> acnts = [SELECT Id, Name FROM Account WHERE ParentId != null];
    // List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgGridItems(acnts[0].Id, Account.getSObjectType());
    SB_Ot_OrgTreeItem.GridItem root = (SB_Ot_OrgTreeItem.GridItem)items[0];
    root.print();
    System.assert(root.label.startsWith(rootAcnt.Name));
  }

  @isTest
  static void test_createOrgTreeItems_by_Contact() {
    Account rootAcnt = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
    List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgTreeItems(conts[0].Id, Contact.getSObjectType());
    SB_Ot_OrgTreeItem.TreeItem root = (SB_Ot_OrgTreeItem.TreeItem)items[0];
    root.print();
    System.assert(root.label.startsWith(rootAcnt.Name));
  }

  @isTest
  static void test_createOrgGridItems_by_Contact() {
    Account rootAcnt = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
    List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgGridItems(conts[0].Id, Contact.getSObjectType());
    SB_Ot_OrgTreeItem.GridItem root = (SB_Ot_OrgTreeItem.GridItem)items[0];
    root.print();
    System.assert(root.label.startsWith(rootAcnt.Name));
  }

}