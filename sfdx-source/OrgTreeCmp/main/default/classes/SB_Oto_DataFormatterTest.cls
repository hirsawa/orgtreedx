/**
 *
 * SB_Oto_DataFormatterTest
 *  SB_Oto_DataFormatter のテストクラス
 *
 *  @author sawano
 *  @Version 1.2 2020.04.xx
 *
 **/
@isTest
private class SB_Oto_DataFormatterTest {

  private class TestDB extends SB_Ot_TestDB {

    public override void initialize() {
      // ユーザを作る
      createUsers();
      // カスタム設定を作る
      createCustomConfig();
    }
  }

  @isTest
  static void test_createFormatters() {
    TestDB db = new TestDB();
    db.initialize();

    Map<String, Schema.SObjectField > fMap = User.getSObjectType().getDescribe().fields.getMap();
    List<Schema.DescribeFieldResult> dfrs = new List<Schema.DescribeFieldResult>();
    for (String f : fMap.keySet()) {
      dfrs.add(fMap.get(f).getDescribe());
    }
    SB_Oto_DataFormatter.createFormatters(dfrs);
    System.assertEquals(fMap.size(), SB_Oto_DataFormatter.formatters.size());
  }

  @isTest
  static void test_Formatters_format() {
    TestDB db = new TestDB();
    db.initialize();

    List<String> fields = new List<String> { 'CompanyName', 'Country', 'Department', 'Title', 'Email', 'Phone', 'Fax', 'EmployeeNumber', 'LanguageLocaleKey', 'Address', 'SmallPhotoUrl' };
    Map<String, Schema.SObjectField > fMap = User.getSObjectType().getDescribe().fields.getMap();
    List<Schema.DescribeFieldResult> dfrs = new List<Schema.DescribeFieldResult>();
    for (String f : fields) {
      dfrs.add(fMap.get(f).getDescribe());
    }
    SB_Oto_DataFormatter.createFormatters(dfrs);

    Id recId =  db.listUser[0].Id;
    String query = String.format('SELECT Id, Name, {0} FROM User WHERE Id=:recId', new String[] { String.join(fields, ', ')});
    List<User> users = Database.query(query);
    for (String f : fields) {
      Object val = users[0].get(f);
      String d = SB_Oto_DataFormatter.getDataFormatter(f).format(val);
      System.assertEquals(true, String.isNotBlank(d), f);
    }

  }

  @isTest
  static void test_NumberFormatter() {
    // Userに数値ってないので、Accountの数値で試します。
    SB_Oto_DataFormatter.NumberFormatter formatter = new SB_Oto_DataFormatter.NumberFormatter(Account.NumberOfEmployees.getDescribe());
    Decimal c = 111111;
    System.assertEquals('111,111', formatter.format(c), 'Decimal');
    Integer n = 111111;
    System.assertEquals('111,111', formatter.format(n), 'Integer');
    Double d = 111111.111;
    System.assertEquals('111,111.111', formatter.format(d), 'Double');
    SB_Oto_DataFormatter.RecordField rf = formatter.build(c);
    System.assertEquals(true, rf.other, 'RecordField.other');
  }
}