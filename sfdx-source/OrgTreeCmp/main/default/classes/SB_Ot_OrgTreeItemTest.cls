/**
 *
 *  SB_Ot_OrgTreeItemTest
 *    SB_Ot_OrgTreeItem のテストクラス  基本的なことのテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx
 *
 */
@isTest
private class SB_Ot_OrgTreeItemTest
{
  @isTest
  static void test_removeTextLine() {
    SB_Ot_OrgTreeItem.TreeItem item = new SB_Ot_OrgTreeItem.TreeItem('ダミー');
    String dept;
    dept = item.removeTextLine('法人コンサルティング&マーケティング本部\nコンサルティング部\n部長', '部長');
    System.assertEquals('法人コンサルティング&マーケティング本部\nコンサルティング部', dept);
  }

  @isTest
  static void test_GridItem_Lead() {
    // カスタム設定をデフォルトからOwenrIdを外して初期化 LeadのOwnerは特別？
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.LeadTreeGridColumns__c = 'Title, Phone, MobilePhone, Email';
    insert config;

    List<Lead> leads = new List<Lead>();
    leads.add(new Lead(Company='渋谷株式会社', FirstName='太郎', LastName='恵比寿', Title='部長', Email='user01@shibuya.com', OwnerId=UserInfo.getUserId()));
    insert leads;

    Lead lead = [SELECT Id, Name, Company, FirstName, LastName, Title, Email, Phone, MobilePhone, Fax, OwnerId, Owner.Name, Owner.Id FROM Lead LIMIT 1];
    System.debug(lead.Owner.Name); // null

    SB_Ot_OrgTreeItem.GridItem item = new SB_Ot_OrgTreeItem.GridItem(lead);

    System.assertEquals(lead.Name, item.label);
  }
}