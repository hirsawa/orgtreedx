/**
 *  SB_Ot_LcRequestObjectPickListTest
 *
 *  SB_Ot_LcRequestObjectPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.05.xx
 *
 **/
@isTest
private class SB_Ot_LcRequestObjectPickListTest {

  @isTest
  static void test_SB_Ot_LcRequestObjectPickList_Account() {
    // カスタム設定の複数オブエジェクト対応の設定
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.MultiObjectActive__c = true;
    config.MultiObject__c = 'Lead,Account,Contact,SmartViscaf__NameCard__c';
    config.MultiObjectTreeGridColumns1__c = 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId, sobject';
    insert config;

    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Account';
    SB_Ot_LcRequestObjectPickList pickList = new SB_Ot_LcRequestObjectPickList(context);
    System.assertEquals('account', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcRequestObjectPickList_Contact() {
    // カスタム設定の複数オブエジェクト対応の設定
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.MultiObjectActive__c = true;
    config.MultiObject__c = 'Lead,Account,Contact,SmartViscaf__NameCard__c';
    config.MultiObjectTreeGridColumns1__c = 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId, sobject';
    insert config;

    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Contact';
    SB_Ot_LcRequestObjectPickList pickList = new SB_Ot_LcRequestObjectPickList(context);
    System.assertEquals('account', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }


}