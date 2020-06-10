/**
 *  SB_Ot_LcDateRangePickListTest
 *
 *  SB_Ot_LcDateRangePickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1    2019.12.xx
 *
 **/
@isTest
private class SB_Ot_LcDateRangePickListTest {

  @isTest
  static void test_SB_Ot_LcDateRangePickList() {
    SB_Ot_LcDateRangePickList pickList = new SB_Ot_LcDateRangePickList();
    System.assertEquals('-1', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assertEquals(SB_Ot_Global.otConfig.MaxDateRange__c + 2, opts.size());
  }

}