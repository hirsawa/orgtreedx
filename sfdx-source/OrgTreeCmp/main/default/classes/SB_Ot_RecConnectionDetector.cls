/**
 * SB_Ot_RecConnectionDetector
 *    複数オブジェクトで構成する場合のオブジェクト間の紐づけの値を得る
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 初版 複数オブジェクト構成対応
 *
 **/
public with sharing class SB_Ot_RecConnectionDetector {
  public class SB_Ot_RecConnectionDetectorException extends Exception {}

  private Id targetId;    // 対象のレコードID

  private String namecardId;  // 取引先か、取引先責任者か、リードで 対象のレコードにあった、名刺レコードへの参照
  private Id ncAccountId;   // 名刺の 取引先 参照
  private Id ncContactId;
  private Id ncLeadId;
  private String orgName;
  private String email;

  // 目的のもの
  // private Map<SObjecttype, String> otype2validOrgName; // オブジェクトごとの会社名、同じはずだけど、個人を特定してそのレコードの会社名なので、
  // private Map<SObjecttype, Id> otype2validId; //
  private List<SObjecttype> otypes;  // 処理の対象にする オブジェクト の
  private Map<SObjecttype, Object> otype2orgNameOrId; // オブジェクトごとの紐付ける会社名かレコードID、会社名は同じはずだけど、個人を特定したレコードの会社名なので、

  private SB_Ot_SObjectConfig objConfig;  // 対象のれコードのオブジェクトの設定
  private SB_Ot_OrgTreeConfig treeConfig; //

  public SB_Ot_RecConnectionDetector(List<SObjectType> otypes, Id targetId) {
    this.otypes = new List<SObjecttype> ();
    this.otypes.addAll(otypes);
    this.targetId =targetId;
    this.otype2orgNameOrId = new Map<SObjecttype, Object>();
    this.objConfig = SB_Ot_SObjectConfig.getSObjectConfig(targetId.getSobjectType());
    this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
  }

  public void run() {
    // 対象のレコードから、関連オブジェクトに紐づく項目の値を取得する、
    makeTargetConnectionValues();
    // 各オブジェクトを紐づける、会社名か、対象オブジェクトのレコードID を求める
    makeDestConnectionValues();
  }

  // 指定オブジェクトに対して、関連付けのもとになる 値を取得 組織名 か レコードID
  public Object getConnectionValue(SObjecttype otype) {
    return this.otype2orgNameOrId.get(otype);
  }

  // 対象のレコードについて 他オブジェクトへの紐付ける項目値を得る。
  private void makeTargetConnectionValues() {
    String query = makeTargetQuery();
    System.debug(query);
    List<SObject> objs = Database.query(query);
    if (objs.isEmpty()) {
      throw new SB_Ot_RecConnectionDetectorException('Failed to query target record\'s fields');
    }
    SObject target = objs[0];
    SObject ncRef;
    if (this.objConfig.isNameCardObject()) {
      // 名刺
      ncRef = target;
    }
    else if (SB_Ot_Global.isEnableSmartVisca() &&
      (this.objConfig.otype == Account.getSObjectType() || this.objConfig.otype == Contact.getSObjectType())) {
      // SV ありの Account or Contact
      ncRef = (SObject)target.getSObject('smartviscaf__namecard__r');
    }
    else if (SB_Ot_Global.isEnableLeadExtension() && this.objConfig.otype == Lead.getSObjectType()) {
      // SV LEX ありの Lead
      ncRef = (SObject)target.getSObject('smartviscal__namecard__r');
    }
    if (ncRef != null) {
      // 上のどれか　SV あり
      this.namecardId = ncRef.Id;
      this.ncAccountId = (Id)ncRef.get('smartviscaf__account__c');
      this.ncContactId = (Id)ncRef.get('smartviscaf__contact__c');
      this.ncLeadId = (Id)ncRef.get('smartviscaf__lead__c');
    }

    // this.orgName = (String)target.get(this.objConfig.orgField); // 組織名
    // 組織名
    setOrgName(target);
    // メアド
    if (String.isNotBlank(this.objConfig.emailField)) {
      this.email = (String)target.get(this.objConfig.emailField); // メアド
    }
  }

  // 選択中レコードから 組織名を取得
  private void setOrgName(SObject target) {
    if (this.objConfig.otype != Contact.getSObjectType()) {
      // Contact 以外
      this.orgName = (String)target.get(this.objConfig.orgField);
    }
    else {
      // Contact
      SObject acnt = (SObject)target.getSObject('Account');
      if (acnt == null) {
        return;
      }
      SB_Ot_SObjectConfig acntObjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSobjectType());
      this.orgName = (String)acnt.get(acntObjConfig.orgField);
    }
  }

  // 各オブジェクトを紐づける、会社名か、対象オブジェクトのレコードID を求める
  private void makeDestConnectionValues() {
    for (SObjectType otype : this.otypes) {
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
      if (this.treeConfig.multiConnectionMethod == SB_Ot_OrgTreeConfig.ConectionMethod.SvReference) {
        // レコードID から レコードを収集
        Id refId = getReferenceId(otype);
        if (isValidReferenceId(refId)) {
          this.otype2orgNameOrId.put(otype, refId);
          continue;
        }
      }
      else if (this.treeConfig.multiConnectionMethod == SB_Ot_OrgTreeConfig.ConectionMethod.Email
            && String.isNotBlank(sobjConfig.emailField)) {      // this.email が NULLでも調べる → 中では,参照でもしらべてる
        SObject target = searchConnectionRecord(otype);
        if (target != null) {
          // メアド該当か、参照該当で、会社名があった
          // 会社名 から レコードを収集
          String orgName = (String)target.get(sobjConfig.orgField);
          System.debug(LoggingLevel.INFO, 'Connction Record orgName: ' + orgName);
          this.otype2orgNameOrId.put(otype, orgName);
        }
      }
      if (!this.otype2orgNameOrId.containsKey(otype)) {
        // 会社名で紐づけか、他の項目で 会社名のある有効なレコードと紐付かないとき
        // 選択レコードの会社名 から レコードを収集
        this.otype2orgNameOrId.put(otype, this.orgName);
      }
    }
  }

  @TestVisible
  private Boolean isValidReferenceId(Id refId){
    SObjectType otype = refId.getSobjectType();
    SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
    String query;
    if (otype == Contact.sObjectType) {
      query= 'SELECT Id, Name, AccountId FROM Contact WHERE Id = :refId';
    }
    else {
      query= String.format('SELECT Id, {0} FROM {1} WHERE Id = :refId',
          new String[] { sobjConfig.orgField, sobjConfig.getSObjectName() } );
    }
    List<SObject> objs = Database.query(query);
    if (objs.isEmpty() ||
      (otype == Contact.sObjectType && objs[0].get('AccountId') == null) ||
      (otype != Contact.sObjectType && objs[0].get(sobjConfig.orgField) == null)) {
      return false;
    }
    return true;
  }
  // 紐づけ項目が 個人特定ようだったら、一旦 個人レコードを探す
  // メール一致指定、でメール一致レコードがなくて、参照先レコードがあれば、それを返す。
  // 両方なければ、NULLで戻る。会社名でレコードを探させる。
  private SObject searchConnectionRecord(SObjectType otype) {
    SObject result;
    SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
    try {
      String query = createSearchConnectionQuery(otype);
      System.debug(LoggingLevel.INFO, query);
      List<SObject> objs = Database.query(query);
      Map<Id, SObject> id2obj = new Map<Id, SObject>(objs);
      if (objs.isEmpty()) {
        return null;
      }
      Id refId = getReferenceId(otype);
      result = id2obj.get(refId);
      // 名刺から参照してる レコード
      if (refId != null &&
          result != null &&
          this.treeConfig.multiConnectionMethod == SB_Ot_OrgTreeConfig.ConectionMethod.SvReference) {
        return result;
      }
      // 選択レコードにメアドがない
      if (String.isBlank(this.email)) {
        return result;
      }
      // アドレスが一致してるレコード
      for (SObject obj : objs) {
        String email = (String)obj.get(sobjConfig.emailField);
        if (email == this.email) {
          result = obj;
          break;
        }
      }
    }
    catch (Exception e) {
      System.debug(LoggingLevel.INFO, e.getMessage());
    }
    return result;
  }

  @TestVisible
  private Id getReferenceId(SObjectType otype) {
    if (otype == Lead.sObjectType) {
      return this.ncLeadId;
    }
    else if (otype == Account.sObjectType) {
      return this.ncAccountId;
    }
    else if (otype == Contact.sObjectType) {
      return this.ncContactId;
    }
    // throw new SB_Ot_RecConnectionDetectorException('invalid SObjectType');
    return null;
  }

  private static String CON_RECORD_QUERY = 'SELECT Id, Name, {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}';
  // 会社名を持つ 個人のレコードを照会してから、そこから同じ会社のレコードを探す
  private String createSearchConnectionQuery(SObjectType otype) {
    // String result;
    SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
    // 取り出す項目
    List<String> validFields = new List<String>();
    validFields.add(sobjConfig.orgField);       // 組織名
    if (String.isNotBlank(sobjConfig.emailField)) {
      validFields.add(sobjConfig.emailField);   // メアド
    }
    String fields = String.join(validFields, ', ');
    // Wehere 句
    List<String> orConditions = new List<String>();
    // 個人を指すEmailアドレスで照会
    if (String.isNotBlank(this.email)) {
      orConditions.add(String.format('{0}=:email', new String[] { sobjConfig.emailField }));
    }
    // 名刺から参照してたら必ず照会する。
    Id refId = getReferenceId(otype);
    if (refId !=null) {
      orConditions.add(String.format('Id=\'\'{0}\'\'', new String[] { refId }));
    }
    String orCondition;
    if (orConditions.isEmpty()) {
       throw new SB_Ot_RecConnectionDetectorException('invalid method call: no person value');
    }
    else if (orConditions.size() == 1) {
      orCondition = orConditions[0];
    }
    else {
      orCondition = '(' + String.join(orConditions, ' OR ') + ')';
    }
    List<String> andConditions = new List<String>();
    andConditions.add(orCondition);
    // 会社があること
    if (otype == Contact.sObjectType) {
      andConditions.add('AccountId!=null'); // 取引先がある
    }
    else {
      andConditions.add(String.format('{0}!=null', new String[] { sobjConfig.orgField })); // 会社項目値がある
    }
    // 追加の検索条件
    andConditions.addAll(sobjConfig.whereExpressions);
    String condition = String.join(andConditions, ' AND ');
    // Order By
    String orderby = sobjConfig.connectionQueryOrderBy;
    // String query = String.format(CON_RECORD_QUERY,
    //           new String[] { fields, sobjConfig.getSObjectName(), condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
    // System.debug(query);
    // this.members = Database.query(query);
    return String.format(CON_RECORD_QUERY,
              new String[] { fields, sobjConfig.getSObjectName(), condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
  }

  // private class ConFiledValue {
  //   public SB_Ot_OrgTreeConfigConectionMethod method { get; private set; } // NULLもあるかも
  //   public String field { get; private set; }
  //   public String value { get; private set; }
  //   public ConFiledValue(String field, String value) {
  //     this.field = field;
  //     this.value = value;
  //     this.method = null;
  //   }
  //   public ConFiledValue(String field, String value, SB_Ot_OrgTreeConfig.ConectionMethod method) {
  //     this.field = field;
  //     this.value = value;
  //     this.method = method;
  //   }
  // }


  // // 他のオブジェクトを紐付ける項目と値 リスト0 番から優先
  // private List<ConFiledValue> getConnectionFiledValue(SObject record) {
  //   List<ConFiledValue> result = new List<ConFiledValue>();
  //   List<String> fields = getConnectionFileds();
  //   for (String f : fields) {
  //     if (f == 'smartviscaf__namecard__c') {
  //       List<ConFiledValue> ncRefValues  = getNameCardRefFieldValue(record);
  //       if (!ncRefValues.isEmpty()) {
  //         result.addAll(ncRefValues);
  //       }
  //     }
  //     else {
  //       String v = (Object)record.get(f);
  //       if (value != null) {
  //         ConFiledValue fv = new ConFiledValue(f, v, getmultiConnectionMethod(f));
  //         result.add(fv);
  //       }
  //     }
  //   }
  //   return result;
  // }

  // private SB_Ot_OrgTreeConfig.ConectionMethod getmultiConnectionMethod(String f) {
  //   if (f == this.objConfig.orgField) {
  //     return SB_Ot_OrgTreeConfig.ConectionMethod.OrgName;
  //   }
  //   else if (f== this.objConfig.emailField) {
  //     return SB_Ot_OrgTreeConfig.ConectionMethod.Email;
  //   }
  //   throw new SB_Ot_RecConnectionDetectorException('invalid method call');
  // }

  // // 他のオブジェクトを紐付ける項目 リスト0 番から優先
  // private List<String> getConnectionFileds() {
  //   List<String> result = new List<String>(); //
  //   switch on this.treeConfig.multiConnectionMethod {
  //     when SB_Ot_OrgTreeConfig.ConectionMethod.OrgName { // 会社名
  //       result.add(this.objConfig.orgField);
  //       if (SB_Ot_Global.isEnableSmartVisca()) {
  //         result.add('smartviscaf__namecard__c');
  //       }
  //       result.add(this.objConfig.emailField);
  //     }
  //     when SB_Ot_OrgTreeConfig.ConectionMethod.Email { // メールアドレス
  //       result.add(this.objConfig.emailField);
  //       if (SB_Ot_Global.isEnableSmartVisca()) {
  //         result.add('smartviscaf__namecard__c');
  //       }
  //       result.add(this.objConfig.orgField);
  //     }
  //     when else { // SB_Ot_OrgTreeConfig.ConectionMethod.SvReference {  // 名刺レコードの参照項目
  //       if (SB_Ot_Global.isEnableSmartVisca()) {
  //         result.add('smartviscaf__namecard__c');
  //       }
  //       result.add(this.objConfig.emailField);
  //       result.add(this.objConfig.orgField);
  //     }
  //   }
  //   return result;
  // }

  // private List<ConFiledValue> getNameCardRefFieldValue(SObject record) {
  //   List<ConFiledValue> result = new List<ConFiledValue> ();
  //   SObject ncObj = record;
  //   if (!this.objConfig.isNameCardObject()) {
  //     // 名刺レコード以外を開いてる
  //     ncObj = record.getSObject('smartviscaf__namecard__c');
  //   }
  //   for (String f : SV_REFERENCE_FIELDS) {
  //     String v = ncObj.get(f);
  //     if (v != null) {
  //       result.put(new ConFiledValue(f, v));
  //     }
  //   }
  //   return result;
  // }

  private static List<String> SV_REFERENCE_FIELDS = new List<String> {
    'smartviscaf__lead__c',
    'smartviscaf__account__c',
    'smartviscaf__contact__c'
  };

  // private static Map<SObjectType, String> SV_OBJ_REFFIELD_MAP = new List<String> {
  //   Lead.sObjectType => 'smartviscaf__lead__c',
  //   Account.sObjectType => 'smartviscaf__account__c',
  //   Contact.sObjectType => 'smartviscaf__contact__c'
  // };

  // private static List<String> SV_CONECTION_FIELDS = new List<String> {
  //   'smartviscaf__company_name__c',
  //   'smartviscaf__email__c',
  //   'smartviscaf__lead__c',
  //   'smartviscaf__account__c',
  //   'smartviscaf__contact__c'
  // };

  private static String TARGET_QUERY = 'SELECT {0} FROM {1} WHERE Id = :targetId';

  // 他のオブジェクトとの紐づく項目値を得るためのクエリ
  private String makeTargetQuery() {
    Set<String> fields = new Set<String>();
    // SV有効なら 名刺の参照項目もクエリする
    if (this.objConfig.isNameCardObject()) {
      // 名刺オブジェクトで探すとき
      fields.addAll(SV_REFERENCE_FIELDS);
    }
    else if (SB_Ot_Global.isEnableSmartVisca() &&
      (this.objConfig.otype == Account.getSObjectType() || this.objConfig.otype == Contact.getSObjectType())) {
      // SV あるの Accout or Contact → 紐づく名刺レコードで調べる
      fields.add('smartviscaf__namecard__c');
      for (String f : SV_REFERENCE_FIELDS) {
        fields.add('smartviscaf__namecard__r.' + f);
      }
    }
    else if (SB_Ot_Global.isEnableLeadExtension() && this.objConfig.otype == Lead.getSObjectType()) {
      // LX あるの Lead → 紐づく名刺レコードで調べる
      fields.add('smartviscal__namecard__c');
      for (String f : SV_REFERENCE_FIELDS) {
        fields.add('smartviscal__namecard__r.' + f);
      }
    }
    // 名刺関連 参照項目以外
    // 組織名
    if (this.objConfig.otype != Contact.getSObjectType()) {
      // Contact 以外
      fields.add(this.objConfig.orgField);
    }
    else {
      // Contact
      fields.add('accountid');
      fields.add('account.name');
      SB_Ot_SObjectConfig acntObjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSobjectType());
      fields.add('account.' + acntObjConfig.orgField);
    }
    if (String.isNotBlank(this.objConfig.emailField)) {
      fields.add(this.objConfig.emailField);   // メアド
    }
    fields.add('id');
    fields.add('name');
    String field = String.join(new List<String>(fields), ', ');
    return String.format(TARGET_QUERY, new String[]{ field, this.objConfig.getSObjectName() });
  }

}