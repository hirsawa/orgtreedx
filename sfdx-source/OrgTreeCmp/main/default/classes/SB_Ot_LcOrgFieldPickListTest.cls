/**
 *  SB_Ot_LcOrgFieldPickListTest
 *  
 *  SB_Ot_LcOrgFieldPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_LcOrgFieldPickListTest {

  @isTest
  static void test_SB_Ot_LcOrgFieldPickList_Contact() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Contact';
    SB_Ot_LcOrgFieldPickList pickList = new SB_Ot_LcOrgFieldPickList(context);
    System.assertEquals('Name', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcOrgFieldPickList_Lead() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Lead';
    SB_Ot_LcOrgFieldPickList pickList = new SB_Ot_LcOrgFieldPickList(context);
    System.assertEquals('Company', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcOrgFieldPickList_Opportunity() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Opportunity';
    SB_Ot_LcOrgFieldPickList pickList = new SB_Ot_LcOrgFieldPickList(context);
    System.assertEquals('None', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }


}