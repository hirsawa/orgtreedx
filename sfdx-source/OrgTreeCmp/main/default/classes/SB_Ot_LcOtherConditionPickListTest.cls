/**
 *  SB_Ot_LcOtherConditionPickListTest
 *
 *  SB_Ot_LcOtherConditionPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1    2019.12.xx
 *
 **/
@isTest
private class SB_Ot_LcOtherConditionPickListTest {

  @isTest
  static void test_SB_Ot_LcOtherConditionPickList_Contact() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.pageType = 'RecordPage';
    context.entityName = 'Contact';

    SB_Ot_LcOtherConditionPickList pickList = new SB_Ot_LcOtherConditionPickList(context);
    System.assertEquals('none', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(SB_Ot_Global.isEnableSmartVisca() ? opts.size() == 1+3+2 : opts.size() == 1+3);
  }

  @isTest
  static void test_SB_Ot_LcOtherConditionPickList_Home() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.pageType = 'HomePage';
    context.entityName = null;
    SB_Ot_Global.otConfig.Development__c = true;

    SB_Ot_LcOtherConditionPickList pickList = new SB_Ot_LcOtherConditionPickList(context);
    System.assertEquals('active', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() == 1+3);
  }

}