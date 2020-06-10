/**
 *
 * SB_Oto_LcRecOwnersSortPickListTest
 *  SB_Oto_LcRecOwnersSortPickList のテストクラス
 *
 *  @author sawano
 *  @Version 1 2019.11.xx
 *
 **/
@isTest
private class SB_Oto_LcRecOwnersSortPickListTest {

  @isTest
  static void test_SB_Oto_LcRecOwnersSortPickList() {
    SB_Oto_LcRecOwnersSortPickList pickList = new SB_Oto_LcRecOwnersSortPickList();
    System.assertEquals('name', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}