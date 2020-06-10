/**
 *
 * SB_Oto_RecordOwnersLwcControllerTest
 *  SB_Oto_RecordOwnersLwcController のテストクラス
 *
 *  @author sawano
 *  @Version1 v1.1 2019.11.xx
 *
 **/
@isTest
private class SB_Oto_RecordOwnersLwcControllerTest {

  private class TestDB extends SB_Ot_TestDB {

    public Id getUserId(Integer index) {
      return listUser.get(index).Id;
    }

    // 子アカウント作成
    protected override List<Account> createChildAccount(List<Account> parents) {
      List<Account> result = new List<Account>();
      for (Account parent : parents) {
        for (Integer n = CNT_USER-2; n < CNT_USER; n++) {
          String cName = parent.Name+'子会社'+ String.valueOf(n).leftPad(3, '0');
          result.add(new Account(Name=cName, ParentId=parent.Id, OwnerId=getUserId(n)));
        }
      }
      insert result;
      return result;
    }

    // コンタクト作成
    protected override List<Contact> createContacts(List<Account> acnts) {
      List<Contact> result = new List<Contact>();
      for (Account acnt : acnts) {
        for (Integer n = 0; n < CNT_USER-2; n++) {
          String lName = acnt.Name+'社員'+String.valueOf(n);
          String fName = String.valueOf(n) + '郎';
          String email = 'user'+String.valueOf(n) +'@' + acnt.Id + '.com';
          result.add(new Contact(LastName=lName, FirstName=fName, Department='開発部 開発課', Title='課長', Email=email, AccountId=acnt.Id, OwnerId=getUserId(n)));
        }
      }
      insert result;
      return result;
    }

    public override void initialize() {
      // ユーザを作る
      createUsers();
      User u = [SELECT Id, Name FROM User LIMIT 1];
      System.runAs(u) {
        List<Account> acnts = new List<Account>();
        List<Contact> conts;
        // ルートのアカウントを作る。 所有者 1番目のユーザ
        acnts.add(new Account(Name='株式会社親商事', OwnerId=listUser[0].Id));  // 1
        insert acnts;
        // ルートアカウント所属のコンタクトを作る
        conts = createContacts(acnts);      // CNT_USER-2
        // 第2階層のアカウントを作る
        acnts = createChildAccount(acnts);      // 2
        // 第2階層のアカウント所属のコンタクトを作る
        conts = createContacts(acnts);      // CNT_USER-2
        // // 第3階層のアカウントを作る
        // acnts = createChildAccount(acnts);      // 3+4
        // // 第3階層のアカウント所属のコンタクトを作る
        // conts = createContacts(acnts);      // 6+8
      }
    }

  }

  @isTest
  static void test_getUsersHavingContacts() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();

    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));

    Contact cont = [SELECT Id FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = SB_Oto_RecordOwnersLwcController.getUsersHavingContacts(
      cont.Id, // Id targetId,
      true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
      true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
      true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
      true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
      'name', // String sortField, // 並び順(初期値)
      true,   // Boolean sortAsc) {   // 昇順          true,
      'CompanyName, Department, Title',
      'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber'); // String fields,        // ユーザの表示項目 ToDo
    System.assertEquals(users.size(), res.owners.size());
  }

}