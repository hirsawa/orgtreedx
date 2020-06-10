/**
 *  SB_Ot_LcDeptFieldPickListTest
 *  
 *  SB_Ot_LcDeptFieldPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_LcDeptFieldPickListTest {

  @isTest
  static void test_SB_Ot_LcDeptFieldPickList_Account() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Account';
    SB_Ot_LcDeptFieldPickList pickList = new SB_Ot_LcDeptFieldPickList(context);
    System.assertEquals('Department', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcDeptFieldPickList_Lead() {
    // Lead は部署項目ないけど、任意のテキスト項目を指定できるので、
    // OrgTreeConfig__c otConfig = OrgTreeConfig__c.getOrgDefaults();  
    // otConfig.LeadDivisionField__c = 'Description';
    // upsert otConfig;

    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Lead';
    SB_Ot_LcDeptFieldPickList pickList = new SB_Ot_LcDeptFieldPickList(context);
    System.assertEquals('None', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

  @isTest
  static void test_SB_Ot_LcDeptFieldPickList_Opportunity() {
    VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
    context.entityName = 'Opportunity';
    SB_Ot_LcDeptFieldPickList pickList = new SB_Ot_LcDeptFieldPickList(context);
    System.assertEquals('None', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }


}