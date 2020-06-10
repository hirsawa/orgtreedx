/**
 *
 * SB_Oto_LcRecOwnersSortOrderPickListTest
 *  SB_Oto_LcRecOwnersSortOrderPickList のテストクラス
 *
 *  @author sawano
 *  @Version 1 の派生 → v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
@isTest
private class SB_Oto_LcRecOwnersSortOrderPickListTest {

  @isTest
  static void test_SB_Oto_LcRecOwnersSortOrderPickList() {
    SB_Oto_LcRecOwnersSortOrderPickList pickList = new SB_Oto_LcRecOwnersSortOrderPickList();
    System.assertEquals('asc', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assertEquals(2, opts.size());
  }

}