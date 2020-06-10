/**
 *  SB_Ot_LcDeptUsagePickListTest
 *  
 *  SB_Ot_LcDeptUsagePickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_LcDeptUsagePickListTest {

  @isTest
  static void test_SB_Ot_LcDeptUsagePickList() {
    SB_Ot_LcDeptUsagePickList pickList = new SB_Ot_LcDeptUsagePickList();
    System.assertEquals('Hierarchy', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}