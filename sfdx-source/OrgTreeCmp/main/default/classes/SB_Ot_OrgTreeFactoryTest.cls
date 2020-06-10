/**
 *
 *  SB_Ot_OrgTreeFactoryTest
 *    SB_Ot_OrgTreeFactory のテストクラス  基本的なことのテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0      2019.03.xx
 *
 */
@isTest
private class SB_Ot_OrgTreeFactoryTest
{

  @TestSetup
  static void setupDB() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();
  }

  @isTest
  static void test_OrgItemsFactory_constructor() {
    SB_Ot_OrgTreeFactory.OrgItemsFactory factory = new SB_Ot_OrgTreeFactory.OrgItemsFactory();
    System.assert(factory.itemBuilder==null);
  }

  @isTest
  static void test_createOrgTreeItems_by_Lead() {
    List<Lead> leads = [SELECT Id, Name, Company FROM Lead];
    // List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgTreeItems(leads[0].Id, Lead.getSObjectType());
    SB_Ot_OrgTreeItem.TreeItem root = (SB_Ot_OrgTreeItem.TreeItem)items[0];
    root.print();
    System.assert(root.label.startsWith(leads[0].Company));
  }

  @isTest
  static void test_createOrgGridItems_by_Lead() {
    List<Lead> leads = [SELECT Id, Name, Company FROM Lead];
    // List<Contact>  conts = [SELECT Id, Name FROM Contact];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgGridItems(leads[0].Id, Lead.getSObjectType());
    SB_Ot_OrgTreeItem.GridItem root = (SB_Ot_OrgTreeItem.GridItem)items[0];
    root.print();
    System.assert(root.label.startsWith(leads[0].Company));
  }

  @isTest
  static void test_createOrgTreeItems_by_Account() {
    // カスタム設定を変更
    SB_Ot_Global.otConfig.AccountAssociation__c = false; // 取引先 親取引先を階層に含め ない。

    List<Account> acnts = [SELECT Id, Name FROM Account WHERE ParentId != null];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgTreeItems(acnts[0].Id, Account.getSObjectType());
    SB_Ot_OrgTreeItem.TreeItem root = (SB_Ot_OrgTreeItem.TreeItem)items[0];
    root.print();
    System.assert(root.label.startsWith(acnts[0].Name));
  }



}