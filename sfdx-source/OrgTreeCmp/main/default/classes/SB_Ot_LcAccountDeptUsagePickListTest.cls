/**
 *  SB_Ot_LcAccountDeptUsagePickListTest
 *  
 *  SB_Ot_LcAccountDeptUsagePickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_LcAccountDeptUsagePickListTest {

  @isTest
  static void test_SB_Ot_LcAccountDeptUsagePickList() {
    SB_Ot_LcAccountDeptUsagePickList pickList = new SB_Ot_LcAccountDeptUsagePickList();
    System.assertEquals('Label', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}