/**
 *  SB_Ot_LcRecordIdFieldPickListTest
 *
 *  SB_Ot_LcRecordIdFieldPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.05.xx
 *  @Version 1.1    2019.11.xx Userレコード対応
 *
 **/
@isTest
private class SB_Ot_LcRecordIdFieldPickListTest {

  @isTest
  static void test_SB_Ot_LcRecordIdFieldPickList_Account() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.pageType = 'RecordPage';
    context.entityName = 'Account';

    SB_Ot_LcRecordIdFieldPickList pickList = new SB_Ot_LcRecordIdFieldPickList(context);
    System.assertEquals('id', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcRecordIdFieldPickList_HomePage() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.pageType = 'HomePage';
    context.entityName = null;
    SB_Ot_Global.otConfig.Development__c = true;

    SB_Ot_LcRecordIdFieldPickList pickList = new SB_Ot_LcRecordIdFieldPickList(context);
    System.assertEquals('user', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() == 1);
  }

}