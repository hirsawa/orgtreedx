@isTest
private class SB_Ot_EtcTest {

  //.design の中のLabelがパッケージにはいらない ?
  @isTest
  static void test_CustomLabel4Package() {
    System.assertEquals(System.Label.SB_Ot_Conf_DisplayModeLabel, System.Label.SB_Ot_Conf_DisplayModeLabel);
    System.assertEquals(System.Label.SB_Ot_Conf_MaxRecsDescript, System.Label.SB_Ot_Conf_MaxRecsDescript);
    System.assertEquals(System.Label.SB_Ot_Conf_MaxRecsLabel, System.Label.SB_Ot_Conf_MaxRecsLabel);
  }
}