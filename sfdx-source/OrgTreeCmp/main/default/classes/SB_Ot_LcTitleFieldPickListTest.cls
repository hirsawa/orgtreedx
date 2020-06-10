/**
 *  SB_Ot_LcTitleFieldPickListTest
 *  
 *  SB_Ot_LcTitleFieldPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_LcTitleFieldPickListTest {

  @isTest
  static void test_SB_Ot_LcTitleFieldPickList_Contact() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Account';
    SB_Ot_LcTitleFieldPickList pickList = new SB_Ot_LcTitleFieldPickList(context);
    System.assertEquals('Title', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcTitleFieldPickList_Lead() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Lead';
    SB_Ot_LcTitleFieldPickList pickList = new SB_Ot_LcTitleFieldPickList(context);
    System.assertEquals('Title', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcTitleFieldPickList_Opportunity() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Opportunity';
    SB_Ot_LcTitleFieldPickList pickList = new SB_Ot_LcTitleFieldPickList(context);
    System.assertEquals('None', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }


}