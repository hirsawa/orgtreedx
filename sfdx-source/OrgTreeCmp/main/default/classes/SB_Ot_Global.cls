/**
 *
 * SB_Ot_Global
 *  グローバルで使う定数
 *          従来 Util でもってたのもこっとに映る
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.12.xx
 *  @Version 1.2    2020.04.xx
 *
 **/
public with sharing class SB_Ot_Global {
  public class SB_Ot_GlobalException extends Exception {}

  // 静的変数
  // 同じ人の表示方法
  // 0: そのまま表示する
  // 1: 表示しない
  // 2: 入れ子にする
  public static final Integer SAME_PERSON_FLAT = 0;
  public static final Integer SAME_PERSON_OFF = 1;
  public static final Integer SAME_PERSON_NEST = 2;

  public static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  public static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name='SB_Ot_Global'];
        if (classes.size() == 1) {
          namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
        }
        else if (classes.size() > 1) {
          namespacePrefix = 'OrgTree';
        }
        else {
          namespacePrefix = '';
        }
      }
      return namespacePrefix;
    }
    private set;
  }

  public static Set<Schema.sObjectType> enableOTypes {
    get {
      if (enableOTypes == null) {
        enableOTypes = new Set<Schema.sObjectType> {
          Account.sObjectType,
          Contact.sObjectType
          // Lead.sObjectType
        };
        if (isEnableSmartVisca()) {
          // パッケージを必須としないように、動的に追加
          enableOTypes.add(getNameCardSObjectType());
        }
      }
      return enableOTypes;
    }
    private set;
  }

  // public static Integer allowedLicenses {
  //   get {
  //     if (allowedLicenses ==null) {
  //       List<PackageLicense> recs = [SELECT Id, AllowedLicenses, NamespacePrefix FROM PackageLicense ];
  //       allowedLicenses = recs.size();
  //     }
  //     return allowedLicenses;
  //   }
  //   private set;
  // }
  // SmartVisca があれば、SObjectType
  @TestVisible
  private static SObjectType nameCardSObjectType;
  private static Boolean enableLeadExtension; // リード拡張パッケージが入ってる？
  static {
    nameCardSObjectType = Schema.getGlobalDescribe().get('SmartViscaf__NameCard__c');
    enableLeadExtension = nameCardSObjectType != null
                          && ![SELECT Id FROM ApexClass WHERE NamespacePrefix = 'SmartViscal'].isEmpty();
  }
  // Map<String, Schema.SObjectField > fieldMap = SB_Ot_Global.getNameCardSObjectType().getDescribe().fields.getMap();
  public static SObjectType getNameCardSObjectType() {
    return nameCardSObjectType;
  }
  public static Boolean isEnableSmartVisca() {
    return nameCardSObjectType != null;
  }
  public static Boolean isEnableLeadExtension() {
    return enableLeadExtension;
  }

  // 名刺以外の名刺の項目があるオブジェクトか？
  public static Boolean isEnableSmartViscaSObject(Schema.SObjectType otype) {
    return isEnableSmartVisca() && ((otype == Account.getSObjectType() || otype == Contact.getSObjectType()) || (isEnableLeadExtension() && otype == Schema.Lead.getSObjectType()));
  }


  // 個人取引先をサポートした組織？
  private static Boolean enablePersonAccount;
  public static Boolean isEnablePersonAccount() {
    if (enablePersonAccount == null) {
      enablePersonAccount = Account.getSObjectType().getDescribe().fields.getMap().containsKey('IsPersonAccount');
    }
    return enablePersonAccount;
  }

  public static Boolean isPersonal(SObject obj) {
    System.assert(enablePersonAccount);
    System.assert(obj.getSObjectType() == Account.getSObjectType() || obj.getSObjectType() == Contact.getSObjectType());
    return (Boolean)obj.get('IsPersonAccount');
  }

  // カスタム設定 OrgTree設定
  public static OrgTreeConfig__c otConfig {
    get {
      if (otConfig == null) {
        otConfig = OrgTreeConfig__c.getInstance(UserInfo.getUserId());   //  個人の設定
        if (otConfig.Id ==null) {
            otConfig =  OrgTreeConfig__c.getInstance(UserInfo.getProfileId());   //プロファイルの設定
        }
        if (otConfig.id == null) {
          otConfig = OrgTreeConfig__c.getOrgDefaults();    // 組織の設定
        }
        if (otConfig.id == null) {
          // カスタム設定がなかったときの省略値たち
          // 部署項目に役職を含む項目 NULLにしていたら、それを採用する！！ので なかったときだけデフォルト値
          otConfig.DepartmentFieldsWithTitle__c = 'SmartViscaf__division_name__c';
          // 選択中のレコードを識別する
          otConfig.EnableSelectedRecordMark__c = true;
          // Treeで自分のレコードを識別する
          otConfig.EnableYourRecordMark__c = true;
          // 取引先 親・子の取引先を階層に含める #AppBuilderでの指定が優先する。
          otConfig.AccountAssociation__c = true;
          // カスタム設定を優先する v1.1
          otConfig.PrioritizeCustomSetting__c = false;
          // 5.複数オブジェクト構成を有効化 v1.1
          otConfig.MultiObjectActive__c = false;
          // 表示形式メニューを表示する
          otConfig.VisibleFormatMenu__c = true;
          // 部署項目の分割方法メニューを表示する
          otConfig.VisibleParserMenu__c = false;
          // 氏名と役職を表示する
          otConfig.NameWithTitle__c = true;
          // 氏名と所有者を表示する
          otConfig.NameWithOwner__c = true;
          // 氏名とメールアドレスを表示する
          otConfig.NameWithEmail__c = false;
          // グリッドでは氏名のみ
          otConfig.NameOnlyInGrid__c = true;
          // 期日の範囲は会計年度を使う
          otConfig.DateRageUseFiscalYear__c = false;
          // 開発モード
          otConfig.Development__c = false;
          // v1.2 グリッドで行番号を表示する
          otConfig.GridShowRowNumberColumn__c	= false;
          // v1.2 グリッドで取引先責任者の役割列はデータがあるときだけ
          otConfig.GridShowContactRoleColumnOnlyWhenData__c = false;
        }
        // 最大取得レコード数
        otConfig.MaxRecords__c = otConfig.MaxRecords__c == null ? 1000 : otConfig.MaxRecords__c;
        // 部門、部署項目を階層に使う場合の部署の分割方法。#AppBuilderでの指定が優先する。
        otConfig.DepartmentParser__c = otConfig.DepartmentParser__c == null ? 0 : otConfig.DepartmentParser__c;   // 部署項目の値を分割しないでそのまま使う  3: 正規表現
        // Gridのラベル欄の初期幅
        otConfig.GridLabelInitialWidth__c = otConfig.GridLabelInitialWidth__c == null ? 300 : otConfig.GridLabelInitialWidth__c;
        // 同じ人の表示方法
        otConfig.SamePersonUsage__c = otConfig.SamePersonUsage__c == null ? SAME_PERSON_FLAT : otConfig.SamePersonUsage__c; // 0: そのまま表示する
        // 期日の範囲の最大値
        otConfig.MaxDateRange__c = otConfig.MaxDateRange__c == null ? 5 : otConfig.MaxDateRange__c;
        // 値がNULLの場合の省略値たち
        if (String.isBlank(otConfig.DepartmentParserSeparater__c)) {
          // 部門、部署の階層の区切り文字   正規表現
          otConfig.DepartmentParserSeparater__c = Label.SB_Ot_DeptParserSeparaterRegex;   // [\s\n]
        }
        // 部門、部署の階層を分割する正規表現
        if (String.isBlank(otConfig.DepartmentParserRegex__c)) {
          otConfig.DepartmentParserRegex__c = Label.SB_Ot_DeptParserRegex;   // 正規表現の省略値
        }
        // 複数オブジェクトで構築 v1.1
        // if (otConfig.Id == null) {  // 初期値
        //   otConfig.MultiObject__c = 'Lead,Account,Contact,SmartViscaf__NameCard__c';
        //   // 5.複数オブジェクトのTreeGridでの表示項目1
        //   otConfig.MultiObjectTreeGridColumns1__c = 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId, sobject';
        // }
        // 5.複数オブジェクトのTreeGridでの表示項目2
        // otConfig.MultiObjectTreeGridColumns2__c = '';
        // 5.複数オブジェクトの紐づけ項目
        // otConfig.MultiObjectConnectionField__c = otConfig.MultiObjectConnectionField__c == null ? 0 : otConfig.MultiObjectConnectionField__c;
        // User
        if (otConfig.Id == null) {// 初期値
          otConfig.UserDivisionField__c = 'Department';
          otConfig.UserTitleField__c = 'Title';
          otConfig.UserEMailField__c = 'Email';
          // otConfig.UserTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail';
        }
        if (String.isBlank(otConfig.UserOrgField__c)) {// 必須
          otConfig.UserOrgField__c = 'CompanyName';
        }
        // removeSmartViscaFields(otConfig.UserTreeGridColumns__c); // SVが無効ならSVの項目を抜く
        if (String.isBlank(otConfig.UserTreeGridColumns__c)) {// 必須
          otConfig.UserTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail';
        }
        otConfig.UserOtherCondition__c = otConfig.UserOtherCondition__c == null ? 1 : otConfig.UserOtherCondition__c; // 対象レコードの条件 1: 有効なユーザのみ
        // Account
        if (otConfig.Id == null) {  // 初期値
          otConfig.AccountDivisionField__c = 'Site';
          // otConfig.AccountTreeGridColumns__c = 'Site, BillingPostalCode, BillingState, BillingCity, BillingStreet, Description, OwnerId';
          otConfig.AccountTreeGridColumns__c = 'SmartViscaf__NameCard__c, OwnerId';
        }
        if (String.isBlank(otConfig.AccountOrgField__c)) { // 必須
          otConfig.AccountOrgField__c = 'Name';
        }
        if (String.isBlank(otConfig.AccountTreeGridColumns__c)) { // 必須
          otConfig.AccountTreeGridColumns__c = 'Id';
        }
        // // 取引先、取引先責任者での階層作成に用いるオブジェクト
        // otConfig.AccountTreeSource__c = otConfig.AccountTreeSource__c == null ? 0 : otConfig.AccountTreeSource__c;   // 両方
        // 部署項目の使用方法。 1: ラベルに追加する 2: 階層にする(未サポート=その他と同処理) その他: 使用しない
        // 2020.04.xx v1.4 SV_ORGTREE-20 カスタム設定「取引先: 部署名の項目の利用方法 」の初期値を 0:使用しない にする。
        otConfig.AccountDepartmentUsage__c = otConfig.AccountDepartmentUsage__c == null ? 0 : otConfig.AccountDepartmentUsage__c;
        otConfig.AccountDateRange__c = otConfig.AccountDateRange__c == null ? -1 : otConfig.AccountDateRange__c; // 期日の範囲 なし
        otConfig.AccountOtherCondition__c = !isEnableSmartVisca() ? 0 : (otConfig.AccountOtherCondition__c == null ? 0 : otConfig.AccountOtherCondition__c); // 対象レコードの条件 SVあるとき、0:なし、1: 名刺への参照があるレコードのみ
        // Contact
        if (otConfig.Id == null) {// 初期値
          otConfig.ContactDivisionField__c = 'Department';
          otConfig.ContactTitleField__c = 'Title';
          otConfig.ContactEMailField__c = 'EMail';
          // otConfig.ContactTreeGridColumns__c = 'Department, Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId';
          otConfig.ContactTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, ContactRole, OwnerId';
          otConfig.ContactOnlyLatest__c = true; // 02.取引先責任者 最新のレコードのみ  NULL なら true
        }
        // removeSmartViscaFields(otConfig.ContactTreeGridColumns__c); // SVが無効ならSVの項目を抜く
        if (String.isBlank(otConfig.ContactTreeGridColumns__c)) {// 必須
          otConfig.ContactTreeGridColumns__c = 'Id';
        }
        otConfig.ContactDateRange__c = otConfig.ContactDateRange__c == null ? -1 : otConfig.ContactDateRange__c; // 期日の範囲 なし
        otConfig.ContactOtherCondition__c = !isEnableSmartVisca() ? 0 : (otConfig.ContactOtherCondition__c == null ? 0 : otConfig.ContactOtherCondition__c); // 対象レコードの条件 SVあるとき、0:なし、1: 名刺への参照があるレコードのみ
        // Lead
        if (otConfig.Id == null) {// 初期値
          otConfig.LeadTitleField__c = 'Title';
          otConfig.LeadEMailField__c = 'Email';
          otConfig.LeadTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail, SmartViscal__NameCard__c, OwnerId';
        }
        if (String.isBlank(otConfig.LeadOrgField__c)) {// 必須
          otConfig.LeadOrgField__c = 'Company';
        }
        // removeSmartViscaFields(otConfig.LeadTreeGridColumns__c); // SVが無効ならSVの項目を抜く
        if (String.isBlank(otConfig.LeadTreeGridColumns__c)) {// 必須
          otConfig.LeadTreeGridColumns__c = 'Id';
        }
        otConfig.LeadDateRange__c = otConfig.LeadDateRange__c == null ? -1 : otConfig.LeadDateRange__c; // 期日の範囲 なし
        otConfig.LeadOtherCondition__c = !isEnableSmartVisca() ? 0 : (otConfig.LeadOtherCondition__c == null ? 0 : otConfig.LeadOtherCondition__c); // 対象レコードの条件 SVあるとき、0:なし、1: 名刺への参照があるレコードのみ
        // NmaeCard
        if (otConfig.Id == null) {// 初期値
          otConfig.NameCardSObjectName__c = 'SmartViscaf__NameCard__c';
          otConfig.NameCardDivisionField__c = 'SmartViscaf__division__c';
          otConfig.NameCardTitleField__c = 'SmartViscaf__title_name__c';
          otConfig.NameCardEmailField__c = 'SmartViscaf__email__c';
          otConfig.NameCardTreeGridColumns__c = 'SmartViscaf__title_name__c, SmartViscaf__email__c, SmartViscaf__card_exchange_date__c, SmartViscaf__account__c, SmartViscaf__contact__c, OwnerId';
        }
        if (String.isBlank(otConfig.NameCardOrgField__c)) {// 必須
          otConfig.NameCardOrgField__c = 'SmartViscaf__company_name__c';
        }
        if (String.isBlank(otConfig.NameCardTreeGridColumns__c)) {// 必須
          otConfig.NameCardTreeGridColumns__c = 'Id';
        }
        otConfig.NameCardDateRange__c = otConfig.NameCardDateRange__c == null ? -1 : otConfig.NameCardDateRange__c; // 期日の範囲 なし
        otConfig.NameCardOtherCondition__c = otConfig.NameCardOtherCondition__c == null ? 1 : otConfig.NameCardOtherCondition__c; // 対象レコードの条件 1: 最新の名刺のみ
        // 所有者
        if (otConfig.Id == null) {// 初期値
          otConfig.OwnerContactOnlyLatest__c = false; // 所有者: 取引先責任者は最新のレコードのみ
        }
        otConfig.OwnerDateRange__c = otConfig.OwnerDateRange__c == null ? -1 : otConfig.OwnerDateRange__c;         // 所有者:対象レコードの期日の範囲
        otConfig.OwnerOtherCondition__c = otConfig.OwnerOtherCondition__c == null ? 0 : otConfig.OwnerOtherCondition__c;   // 所有者:対象レコードの条件
        otConfig.TimeoutMargin__c = otConfig.TimeoutMargin__c == null ? 50 : otConfig.TimeoutMargin__c;   // v1.2 タイムアウトまでの時間(ミリ秒)
        otConfig.GridUrlTarget__c = String.isBlank(otConfig.GridUrlTarget__c) ? '_self' : otConfig.GridUrlTarget__c; // v1.2 グリッドのURLデータのtarget
      }
      return otConfig;
    }
    private set;
  }

}