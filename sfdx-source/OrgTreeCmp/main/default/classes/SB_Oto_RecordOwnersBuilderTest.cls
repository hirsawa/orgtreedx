/**
 *
 * SB_Oto_RecordOwnersBuilderTest
 *  SB_Oto_RecordOwnersBuilder のテストクラス
 *
 *  @author sawano
 *  @Version1 v1.1 2019.11.xx
 *
 **/
@isTest
private class SB_Oto_RecordOwnersBuilderTest {

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
      // カスタム設定を作る
      createCustomConfig();
    }

    public List<User> getOrderedUsers(String orderBy) {
      Set<Id> userIds = new Set<Id> ((new Map<Id, User>(listUser)).keySet());
      String query = String.format('SELECT Id, Name, CompanyName, Department, Title, EMail FROM User WHERE Id IN :userIds ORDER BY {0}', new String[] { orderBy });
      return Database.query(query);
    }

  }

  @isTest
  static void test_create_by_rootAccout_AssociationOff() {
    TestDB db = new TestDB();
    db.initialize();

    Account acnt = [SELECT Id, OwnerId FROM Account WHERE ParentId=null LIMIT 1];
    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact WHERE AccountId=:acnt.Id)]));
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account WHERE ParentId=null)]));
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        acnt.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        false,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(users.size(), res.owners.size());
  }


  @isTest
  static void test_create_by_rootAccout_AssociationOn() {
    TestDB db = new TestDB();
    db.initialize();

    Account acnt = [SELECT Id, OwnerId FROM Account WHERE ParentId=null LIMIT 1];
    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        acnt.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    // System.assertEquals(cOwners.size()+aOwners.size(), res.owners.size());
    System.assertEquals(users.size(), res.owners.size());
  }


  @isTest
  static void test_create_by_contact_AssociationOn_AccountOwnerOn() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(users.size(), res.owners.size());
  }


  @isTest
  static void test_create_by_contact_AssociationOn_AccountOwnerOff() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    // users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        false,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(users.size(), res.owners.size());
  }


  // 転職前後の名刺も含める 名前でソート
  @isTest
  static void test_create_traceChangeJob_sortName() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    List<User> users = db.getOrderedUsers('Name ASC');
    System.assertEquals(users[0].Name, res.owners[0].name);
    System.assertEquals(users[0].Id, res.owners[0].id);
  }

  // 転職前後の名刺も含める 名前でソート 降順
  @isTest
  static void test_create_traceChangeJob_sortName_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'name', // String sortField, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    List<User> users = db.getOrderedUsers('Name DESC');
    System.assertEquals(users[0].Name, res.owners[0].name);
    System.assertEquals(users[0].Id, res.owners[0].id);
  }

  // 転職前後の名刺も含める 部署でソート
  @isTest
  static void test_create_traceChangeJob_sortDept() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'department', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    List<User> users = db.getOrderedUsers('Department ASC');
    System.assertEquals(users[0].Name, res.owners[0].name);
    System.assertEquals(users[0].Id, res.owners[0].id);
  }

  // 転職前後の名刺も含める 部署でソート 降順
  @isTest
  static void test_create_traceChangeJob_sortDept_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        true,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'department', // String sortField, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(db.listUser.size(), res.owners.size()); // このレコード所有者を含める オフ
    // System.assertEquals([SELECT Id FROM NameCard__c].size(), res.cards.size()); // 転職前後で 全部
    List<User> users = db.getOrderedUsers('Department DESC');
    for (SB_Oto_RecordOwnersBuilder.RecordOwner o : res.owners) {
      System.debug(o.id + ': ' + o.department);
    }
    System.assertEquals(users[0].Name, res.owners[0].name);
    System.assertEquals(users[0].Id, res.owners[0].id);
  }

  // 転職前後の名刺も含める 名刺交換日でソート
  @isTest
  static void test_create_traceChangeJob_sortLastDate() {
    TestDB db = new TestDB();
    db.initialize();

    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    // users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));
    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        false,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'lastDate', // String sortField, // 並び順(初期値)
        true,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(users.size(), res.owners.size()); // このレコード所有者を含める オフ
    Set<Id> userIds = users.keySet();
    List<Contact> conts = [SELECT Id, Name, OwnerId, Owner.Name FROM Contact WHERE OwnerId IN :userIds ORDER BY LastModifiedDate ASC];
    System.assertEquals(conts[0].Owner.Name, res.owners[0].name);
    System.assertEquals(conts[0].OwnerId, res.owners[0].id);
  }

  // 転職前後の名刺も含める 名刺交換日でソート LastModifiedDate
  @isTest
  static void test_create_traceChangeJob_sortLastDate_Desc() {
    TestDB db = new TestDB();
    db.initialize();

    Map<Id, User> users = new Map<Id, User>();
    users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Contact)]));
    // users.putAll(new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM Account)]));
    Contact cont = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        cont.Id, // Id targetId,
        true,   // Boolean includeInactiveUser,  // 無効なユーザも含める
        true,   // Boolean includeAccountOwner,  // 取引先の所有者を含む
        false,   // Boolean accountAssociation, // 親・子取引先の所有者を含める
        true,   // Boolean showLastModifiedDate, // 最終更新日を表示する
        'lastDate', // String sortField, // 並び順(初期値)
        false,   // Boolean sortAsc) {   // 昇順          true,
        'CompanyName, Department, Title',
        'CompanyName, Country, Department, Title, Email, Phone, Fax, EmployeeNumber, LanguageLocaleKey, Address, SmallPhotoUrl'); // String fields,        // ユーザの表示項目 ToDo
    SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse res = builder.create();
    System.assertEquals(users.size(), res.owners.size()); // このレコード所有者を含める オフ
    Set<Id> userIds = users.keySet();
    List<Contact> conts = [SELECT Id, Name, OwnerId, Owner.Name FROM Contact WHERE OwnerId IN :userIds ORDER BY LastModifiedDate DESC];
    System.assertEquals(conts[0].Owner.Name, res.owners[0].name);
    System.assertEquals(conts[0].OwnerId, res.owners[0].id);
  }

}