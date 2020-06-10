/**
 *
 *  SB_Ot_OrgTreeFactoryTest5
 *    SB_Ot_OrgTreeFactory のテストクラス  取引先指定なしの取引先責任者 の階層ノード作成 のテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.12.xx
 *
 */
@isTest
private class SB_Ot_OrgTreeFactoryTest5 {

  @TestSetup
  static void setupContacs() {
    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='一人', FirstName='太郎', Department='開発部 開発課', Title='課長', Email='taro@noaccount.com', AccountId=null));
    conts.add(new Contact(LastName='一人', FirstName='次郎', Department='営業部 営業課', Title='課長', Email='jiro@noaccount.com', AccountId=null));
    insert conts;

  }

  @isTest
  static void test_createOrgTreeItems_by_SoloContact() {
    // カスタム設定の複数オブエジェクト対応の設定
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.AccountOtherCondition__c = 0;
    config.ContactOtherCondition__c = 0;
    insert config;
    List<Contact> conts = [SELECT Id, Name FROM Contact WHERE AccountId = null];

    List<SB_Ot_OrgTreeItem.Item> items = SB_Ot_OrgTreeFactory.createOrgTreeItems(conts[0].Id, Account.sObjectType);
    SB_Ot_OrgTreeItem.TreeItem root = (SB_Ot_OrgTreeItem.TreeItem)items[0];
    root.print();
    System.assertEquals(System.Label.SB_Ot_Text_NotHaveAccount, root.label);
    System.assertEquals(1, root.items[0].items.size());
  }

}