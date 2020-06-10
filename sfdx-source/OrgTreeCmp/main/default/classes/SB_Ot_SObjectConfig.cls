/**
 *
 * SB_Ot_SObjectConfig
 *
 * オブジェクトごとの設定情報を保持
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0      2019.03.xx
 *  @Version 1.1      2019.05.xx    複数オブジェクト構成対応
 *
 **/
public with sharing class SB_Ot_SObjectConfig {
  public class SB_Ot_SObjectConfigException extends Exception {}

  private static Integer counter = 0;

  // private static Map<String, Integer> MAP_OTHERCONDITION = new Map<String, Integer> {
  //   'haveNC' => 1,
  //   'haveLatestNC' => 2,
  //   'haveNoChangeLatestNC' => 3,
  //   'latest' => 1,
  //   'noChangeLatest' => 2,
  //   'active' => 1,
  //   'sameOrg' => 2,
  //   'sameOrgActive' => 3
  // };

  // private static Integer getOtherConditionValue(String text) {
  //   return MAP_OTHERCONDITION.containsKey(text) ? MAP_OTHERCONDITION.get(text) : 0;
  // }

  public with sharing class SObjectCondition {
    public Integer value { get; private set; }
    public String key { get; private set; }
    public String label { get; private set; }
    public SObjectCondition(Integer value, String key, String label) {
      this.value = value;
      this.key = key;
      this.label = label;
    }
  }

  private static Map<Schema.SObjectType, Map<Integer, SObjectCondition>> MAP_OTHERCONDITIONS = new Map<Schema.SObjectType, Map<Integer, SObjectCondition>> {
    Account.getSObjectType() => new Map<Integer, SObjectCondition> { 1 => new SObjectCondition(1, 'haveNC', System.Label.SB_Ot_HaveNameCardReference),
                                            2 => new SObjectCondition(2, 'haveLatestNC', System.Label.SB_Ot_HaveLatestNameCardReference),
                                            3 => new SObjectCondition(3, 'haveNoChangeLatestNC', System.Label.SB_Ot_HaveNoChangeLatestNameCardReference) },
    Contact.getSObjectType() => new Map<Integer, SObjectCondition> { 1 => new SObjectCondition(1, 'haveNC', System.Label.SB_Ot_HaveNameCardReference),
                                            2 => new SObjectCondition(2, 'haveLatestNC', System.Label.SB_Ot_HaveLatestNameCardReference),
                                            3 => new SObjectCondition(3, 'haveNoChangeLatestNC', System.Label.SB_Ot_HaveNoChangeLatestNameCardReference) },
    Lead.getSObjectType() => new Map<Integer, SObjectCondition> { 1 => new SObjectCondition(1, 'haveNC', System.Label.SB_Ot_HaveNameCardReference),
                                            2 => new SObjectCondition(2, 'haveLatestNC', System.Label.SB_Ot_HaveLatestNameCardReference),
                                            3 => new SObjectCondition(3, 'haveNoChangeLatestNC', System.Label.SB_Ot_HaveNoChangeLatestNameCardReference) },
    SB_Ot_Global.getNameCardSObjectType() => new Map<Integer, SObjectCondition> { 1 => new SObjectCondition(1, 'latest', System.Label.SB_Ot_LatestNameCards),
                                            2 => new SObjectCondition(2, 'noChangeLatest', System.Label.SB_Ot_NoChangeLatestCards) },
    User.getSObjectType() => new Map<Integer, SObjectCondition> { 1 => new SObjectCondition(1, 'active', System.Label.SB_Ot_OnlyActiveUsers),
                                            2 => new SObjectCondition(2, 'sameOrg', System.Label.SB_Ot_OnlySameOrgUsers),
                                            3 => new SObjectCondition(3, 'sameOrgActive', System.Label.SB_Ot_OnlySameOrgActiveUsers)
                                            }
  };

  private static String getOtherConditionKey(Schema.SObjectType otype, Integer value) {
    if (MAP_OTHERCONDITIONS.get(otype).containsKey(value)) {
      return MAP_OTHERCONDITIONS.get(otype).get(value).key;
    }
    return 'none';
  }

  private static String getOtherConditionSetting(Schema.SObjectType otype)  {
    if (otype == Account.getSObjectType()) {
      return getOtherConditionKey(otype, SB_Ot_Global.otConfig.AccountOtherCondition__c.intValue());
    }
    else if (otype == Contact.getSObjectType()) {
      return getOtherConditionKey(otype, SB_Ot_Global.otConfig.ContactOtherCondition__c.intValue());
    }
    else if (otype == SB_Ot_Global.getNameCardSObjectType()) {
      return getOtherConditionKey(otype, SB_Ot_Global.otConfig.NameCardOtherCondition__c.intValue());
    }
    else if (otype == User.getSObjectType()) {
      return getOtherConditionKey(otype, SB_Ot_Global.otConfig.UserOtherCondition__c.intValue());
    }
    return 'none';
  }

  private with sharing class GridColumn {
    public String fapi { get; private set; }
    public String label { get; private set; }
    public Schema.DisplayType dtype { get; private set; }
    public String colId { get; private set; }
    public GridColumn(DescribeFieldResult dfr, Integer num) {
      this.fapi = dfr.getName();
      this.label = dfr.getLabel();
      this.dtype = dfr.getType();
      this.colId = 'col' + String.valueOf(num);
    }
  }
    // protected SObjectType otype;
    // protected String orgConfig;
    // protected String deptConfig;
    // protected String titleConfig;
    // protected String emailConfig;
    // protected String columnsConfig;
  public Integer dateRange { get; private set; }
  public String otherCondition { get; private set; }
    // protected String whereConfig;
  public String id { get; private set; } // 識別子 番号 オブジェクトAPI名とかだと長いので
  public SObjectType otype { get; private set; }
  public Map<string, Schema.SObjectField> fieldMap;//  = otype.getDescribe().fields.getMap();
  public String orgField { get; private set; }  // 組織名項目 ToDo アカウント、コンタクトのとき
  public String deptField { get; private set; } // 部署項目
  public Boolean deptFieldMultiple { get; private set; } // 部署項目は 複数行
  public Boolean deptFieldWithTitle { get; private set; } // 部署項目に役職が含まれる。 SmartVisca 所属役職項目を想定
  public Boolean removeTitleInDept  { get; private set; } // ToDo: 部署項目から役職を削除する
  public Boolean removeTitleLineInDept  { get; private set; } // ToDo: 部署項目から役職のある行を削除する　 複数行のとき
  public String titleField { get; private set; }
  public String emailField { get; private set; }
  public List<String> gridFields { get; private set; }
  public Boolean showContactRole { get; private set; }  // 取引先責任者の役割を表示する
  public Boolean showNameCardOld { get; private set; }  // 取引先・取引先責任者で最新の名刺を参照しているかを表示する
  // public String whereExpression { get; private set; }
  public List<String> whereExpressions { get; private set; }
  public String connectionQueryOrderBy { get; private set; } // 複数オブジェクトを個人で関連づけるときの クエリの Order By  のあと
  public Boolean onlyLatest { get; private set; }  // 同一内容のレコードでは最新のものだけに絞る
  private SB_Ot_LabelFormatter.LabelFormatter labelFormatter;
  public Map<String, SB_Ot_LcTreeGridDataCreator.DataCreator> dataCreators { get; private set; } // Gridの各列に表示するデータを作るクラスのコレクション
  private Map<Schema.SObjectField, Map<String, String>> field2Picklists;    // 選択項目ごとの値と表示ラベルのマップのマップ
  public Boolean isNameCardObject() {// 名刺オブジェクト？
    return this.otype == SB_Ot_Global.getNameCardSObjectType();
  }
  public Boolean isSmartVisca() {
    return otype.getDescribe().getName() == 'SmartViscaf__NameCard__c';
  }
  // この設定の対象の オブジェクトAPI名
  public String getSObjectName() { return otype.getDescribe().getName(); }
  // この設定の対象の オブジェクト ラベル
  public String getSObjectLabel() { return otype.getDescribe().getLabel(); }

  // クエリする 項目API名
  public Set<String> getQueryFields() {
    Set<String> result = new Set<String>();

    if (String.isNotBlank(this.orgField)) {
      result.add(this.orgField);
    }
    if (String.isNotBlank(this.deptField)) {
      result.add(this.deptField);
    }
    if (String.isNotBlank(this.titleField)) {
      result.add(this.titleField);
    }
    if (String.isNotBlank(this.emailField)) {
      result.add(this.emailField);
    }
    result.addAll(getNoNullSet(this.gridFields));
    result.addAll(getRefNameFields(result));
    result.add('id');
    result.add('name');
    if (this.otype != User.getSObjectType()) {
      result.add('owner.id');
      result.add('owner.name');
    }
    if (SB_Ot_Global.isEnableSmartViscaSObject(this.otype)) {
      // SV有効で、SVへの参照のあるオブジェクトだったら
      result.add('smartviscaf__namecard__c');
      result.add('smartviscaf__namecard__r.smartviscaf__parent__c');
      result.add('smartviscaf__namecard__r.smartviscaf__saishin__c');
      result.add('smartviscaf__namecard__r.smartviscaf__tenshokugonomeishi__c');
      result.add('smartviscaf__namecard__r.smartviscaf__tenshokuzumi__c');
    }
    if (this.otype == Account.getSObjectType() && SB_Ot_Global.isEnablePersonAccount()) {
      result.add('ispersonaccount'); // 個人取引先を示す項目
      result.add('recordtype.name'); // レコードタイプ名 ラベルに使うように
    }
    result.add('lastmodifieddate');
    result.remove('contactrole'); // 'ContactRole' を除外
    return result;
  }

  @TestVisible
  private Set<String> getNoNullSet(List<String> vals) {
    Set<String> result = new Set<String>();
    for(String v : vals) {
      if (String.isNotBlank(v) && !SB_Ot_MultiObjectConfig.SPECIAL_COLUMNS.containsKey(v)) {
        // 空白と、オブジェクト項目でないのは除く
        result.add(v);
      }
    }
    return result;
  }

  // private static final String QUERY_TEMPL_WOL = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}';
  // private static final String QUERY_TEMPL_W = 'SELECT {0} FROM {1} WHERE {2} ';
  // private static final String QUERY_TEMPL_SUB_W = 'SELECT {0}, ({1}) FROM {2} WHERE {3}';

  // private static final String QUERY_TEMPL_TARGET = 'SELECT Id, {0} FROM {1} WHERE Id=:targetId LIMIT 1';

  // SOQL の Order by で指定する項目 Accout、Lead の会社名の項目 も
  //  ' ASC NULLS LAST, 'は Orderby 文字列作るときに つける
  public List<String> getOrderByFields() {
    List<String> result = new List<String>();
    if (String.isNotBlank(this.orgField)) {
      result.add(this.orgField);
    }
    if (String.isNotBlank(this.deptField)) {
      result.add(this.deptField);
    }
    if (String.isNotBlank(this.titleField)) {
      result.add(this.titleField);
    }
    return result;
  }

  public String getPickListLabel(Schema.SObjectField sof, String val) {
    System.assert(this.field2Picklists.containsKey(sof));
    return this.field2Picklists.get(sof).get(val);
  }

  // SB_Ot_SObjectConfig soc = SB_Ot_SObjectConfig.getSObjectConfig(SmartViscaf__NameCard__c.sObjectType);
  // List<SObject> objs = soc.getCoworkerRecords('a077F000005z4ioQAA');
  //
  // public List<SObject> getCoworkerRecords(Id targetId) {
  //   String query;
  //   String orgName;
  //   try {
  //     String targetQuery = String.format(QUERY_TEMPL_TARGET, new String[] { this.orgField, getSObjectName()});
  //     System.debug(targetQuery);
  //     SObject targetObj = Database.query(targetQuery);
  //     orgName = (String)targetObj.get(this.orgField);
  //     if (String.isBlank(orgName)) {
  //       Map<String, Schema.SObjectField > fMap = this.otype.getDescribe().fields.getMap();
  //       throw new SB_Ot_SObjectConfigException(String.format('{0}がありません。', new String[] { fMap.get(this.orgField).getDescribe().getLabel() }));
  //     }
  //     String fields = String.join(new List<String>(getQueryFields()), ', ');
  //     String condition = String.format('{0}=:orgName', new String[] { this.orgField });
  //     String orderby = String.join(getOrderByFields(), ', ');
  //     query = String.format(QUERY_TEMPL_WOL,
  //               new String[] { fields, getSObjectName(), condition, orderBy, String.valueOf(SB_Ot_Global.otConfig.MaxRecords__c)});
  //     System.debug(query);
  //   }
  //   catch(Exception e) {
  //     throw new SB_Ot_SObjectConfigException('Invalid record Id: ' + targetId);
  //   }
  //   return Database.query(query);
  // }

    // Map<string, Schema.SObjectField> fieldMap = SmartViscaf__NameCard__c.sObjectType.getDescribe().fields.getMap();
    // Schema.DescribeFieldResult descField = fieldMap.get('SmartViscaf__account__c').getDescribe();
    // List <Schema.sObjectType> q = descField.getReferenceTo();
  // 参照項目だったら、参照先の Name も取得するように
  private Set<String> getRefNameFields(Set<String> fields) {
    // Map<string, Schema.SObjectField> fieldMap = otype.getDescribe().fields.getMap();
    Set<String> result = new Set<String>();
    for (String f : fields) {
      if (!this.fieldMap.containskey(f)) {
        continue;
      }
      Schema.DescribeFieldResult descField = this.fieldMap.get(f).getDescribe();
      if (descField.getType() != Schema.DisplayType.REFERENCE) {
        continue;
      }
      if (f.endsWithIgnoreCase('__c')) {
        result.add(f.removeEndIgnoreCase('__c') + '__r.name');
      }
      else if(f.endsWithIgnoreCase('id')) {
        result.add(f.removeEndIgnoreCase('id') + '.name');
      }
    }
    return result;
  }

  public SB_Ot_SObjectConfig(SObjectType otype) {
    this.id = String.valueOf(++counter);
    this.otype = otype;
    this.fieldMap = otype.getDescribe().fields.getMap();
    this.dateRange = -1;  // 期日の範囲の条件なし
    this.otherCondition = 'none';   // 所定の条件なし
    this.gridFields = new List<String>();
    this.showContactRole = false;
    this.showNameCardOld = SB_Ot_Global.isEnableSmartViscaSObject(this.otype); // SVあれば、取引先、取引先責任者,リードで最新の名刺を参照しているかを表示する
    this.whereExpressions = new List<String>();
    this.onlyLatest = false;      // 同一内容のレコードでは最新のものだけに絞る
    this.deptFieldMultiple = false;
    this.deptFieldWithTitle = false;
    this.removeTitleInDept = false;      // 部署項目から役職を削除する
    this.removeTitleLineInDept = false; // 部署項目から役職のある行を削除する　 複数行のとき
    // 複数オブジェクトを個人で関連づけるときの クエリの Order By  のあと
    this.connectionQueryOrderBy = 'LastModifiedDate DESC NULLS LAST';  // とりあえず固定で
  }

  private static final Set<Schema.DisplayType> VALID_DEPT_FIELD_TYPES = new Set<Schema.DisplayType> { Schema.DisplayType.String, Schema.DisplayType.TEXTAREA };
  private static final Set<Schema.DisplayType> VALID_EMAIL_FIELD_TYPES = new Set<Schema.DisplayType> { Schema.DisplayType.String, Schema.DisplayType.Email };

  public void init(String orgConfig, String deptConfig, String titleConfig, String emailConfig, String columnsConfig,
                    Integer dateRange, String otherCondition, String whereConfig, Boolean latest) {
    this.dateRange = dateRange;
    this.otherCondition = otherCondition;
    this.onlyLatest = latest;
    // Map<String, Schema.SObjectField > fMap = otype.getDescribe().fields.getMap();
    // していされてる項目の存在チェック
    List<String> reqFields = new List<String> { orgConfig, deptConfig, titleConfig, emailConfig };
    if (String.isNotBlank(columnsConfig)) {
      reqFields.addAll(columnsConfig.split(',\\s*'));
    }
    // 指定された項目の妥当性チェック
    validateConfigFields(reqFields, this.fieldMap);
    // 組織名の項目
    if (String.isNotBlank(orgConfig)) {
     if (this.fieldMap.containsKey(orgConfig) && this.fieldMap.get(orgConfig).getDescribe().getType()==Schema.DisplayType.String) {
      this.orgField = orgConfig.toLowerCase();
      }
      else {
        throw new SB_Ot_SObjectConfigException(String.format(Label.Sb_Ot_Text_Invalid3, new String[] { OrgTreeConfig__c.getSObjectType().getDescribe().getLabel(), Label.SB_Ot_Conf_OrganizationField, orgConfig }));
      }
    }
    // 部署名の項目
    if (String.isNotBlank(deptConfig)) {
      if (this.fieldMap.containsKey(deptConfig) && VALID_DEPT_FIELD_TYPES.contains(this.fieldMap.get(deptConfig).getDescribe().getType())) {
        this.deptField = deptConfig.toLowerCase();
        this.deptFieldMultiple = this.fieldMap.get(deptConfig).getDescribe().getType() == Schema.DisplayType.TEXTAREA;
        if (String.isNotBlank(SB_Ot_Global.otConfig.DepartmentFieldsWithTitle__c)) {
          // 役職が含まれた部署項目か？
          Set<String> ss = new Set<String>(SB_Ot_Global.otConfig.DepartmentFieldsWithTitle__c.split('[,\\s]+'));
          this.deptFieldWithTitle = ss.contains(deptConfig);
        }
      }
      else {
        throw new SB_Ot_SObjectConfigException(String.format(Label.Sb_Ot_Text_Invalid3, new String[] { OrgTreeConfig__c.getSObjectType().getDescribe().getLabel(), Label.SB_Ot_Conf_DivisionField, deptConfig }));
      }
    }
    // 役職名の項目
    if (String.isNotBlank(titleConfig)) {
      if (this.fieldMap.containsKey(titleConfig) && this.fieldMap.get(titleConfig).getDescribe().getType()==Schema.DisplayType.String) {
        this.titleField = titleConfig.toLowerCase();
      }
      else {
        throw new SB_Ot_SObjectConfigException(String.format(Label.Sb_Ot_Text_Invalid3, new String[] { OrgTreeConfig__c.getSObjectType().getDescribe().getLabel(), Label.SB_Ot_Conf_TitleField, titleConfig }));
      }
    }
    // メールアドレスの項目
    if (String.isNotBlank(emailConfig)) {
      if (this.fieldMap.containsKey(emailConfig) && VALID_EMAIL_FIELD_TYPES.contains(this.fieldMap.get(emailConfig).getDescribe().getType())) {
        this.emailField = emailConfig.toLowerCase();
      }
      else {
        throw new SB_Ot_SObjectConfigException(String.format(Label.Sb_Ot_Text_Invalid3, new String[] { OrgTreeConfig__c.getSObjectType().getDescribe().getLabel(), Label.SB_Ot_Conf_EmailField, emailConfig }));
      }
    }
    // グリッドの表示項目
    List<String> gridFields = new List<String>();
    if (String.isNotBlank(columnsConfig)) {
      // グリッドに表示する項目
      for (String f : columnsConfig.toLowerCase().split(',\\s*')) {
        if (f=='ContactRole' && SB_Ot_ContactRoleFormatter.isEnableContactRole(this.otype)) {
          this.showContactRole = true; // 取引先責任者の役割を表示する
        }
        else {
          if (gridFields.contains(f)) continue;     // 重複ならスキップ
          if (!this.fieldMap.containsKey(f)) continue;     // API名不正ならスキップ
          if (ignoreDisplayTypes.contains(this.fieldMap.get(f).getDescribe().getType())) continue;  // 処理対象外のデータ型
          if (!this.fieldMap.get(f).getDescribe().isAccessible()) continue; // 参照負荷ならスキップ  グリッドにだすだけの項目は参照負荷でもエラーにしない。
          if (this.fieldMap.get(f).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
            for (Schema.SObjectType ot : this.fieldMap.get(f).getDescribe().getReferenceTo()) {
              if (!ot.getDescribe().isAccessible()) {
                continue; // 参照項目で参照負荷ならスキップ
              }
            }
          }
        }
        gridFields.add(f);
        if (f!='ContactRole' && this.fieldMap.get(f).getDescribe().getType() == Schema.DisplayType.Picklist) {
          addPiklistValues(this.fieldMap.get(f));
        }
      }
    }
    this.gridFields.addAll(gridFields);
    this.whereExpressions.addAll(makeConditions(dateRange, otherCondition));
    if (String.isNotBlank(whereConfig)) {
      this.whereExpressions.add(whereConfig);
    }
    createLabelFormatter();
    createDataCreators();
  }

  private void addPiklistValues(Schema.SObjectField f) {
    System.assertEquals(Schema.DisplayType.Picklist, f.getDescribe().getType());
    if (this.field2Picklists == null) {
      this.field2Picklists = new Map<Schema.SObjectField, Map<String, String>>();
    }
    this.field2Picklists.put(f, getPickListEntry(f));
  }

  // 項目の選択リスト値のリストを取得
  private Map<String, String> getPickListEntry(Schema.SObjectField f) {
    System.assertEquals(Schema.DisplayType.Picklist, f.getDescribe().getType());
    Map<String, String> result = new Map<String, String>();
    try {
      List<Schema.PicklistEntry> entries = f.getDescribe().getPicklistValues();
      for (Schema.PicklistEntry ent : entries) {
        if (ent.isActive()) {
          result.put(ent.getValue(), ent.getLabel());
        }
        if (ent.isDefaultValue()) {
          System.debug('Default : ' + ent.getLabel());
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
    return result;
  }



  // 項目API名の存在チェック
  private void validateConfigFields(List<String> fields, Map<String, Schema.SObjectField > fMap) {
    List<String> badFields = new List<String>();
    // List<String> disableAccessFs = new List<String>();
    for (String f : fields) {
      if (f == 'SmartViscaf__NameCard__c' || f == 'SmartViscal__NameCard__c' || f == 'ContactRole') {
        // 名刺用の2つはインストールされてればあるし、ないならないで、あとでグリッドの要素にくわえないので、 スルーでOK
        // ContactRole は 取引先責任者の役割のこと
        continue;
      }
      if (String.isNotBlank(f) && !fMap.containsKey(f)) {
        // ない項目API名
        badFields.add(f);
      }
      // アクセス権のない項目していされててもエラーにしない、スルーする。
      // else if (String.isNotBlank(f)) {
      //   // 項目アクセス権のチェック
      //   Schema.DescribeFieldResult descField = fMap.get(f).getDescribe(); // NULLはない
      //   if (!descField.isAccessible()) {
      //     disableAccessFs.add(f);
      //   }
      // }
    }
    String err = '';
    if (!badFields.isEmpty()) {
      err = 'Invalid filed name (' + String.join(badFields, ', ') + ')';
    }
    // if (!disableAccessFs.isEmpty()) {
    //   err += String.isNotBlank(err) ? ', ' : '';
    //   err += 'Insufficient permission (' + String.join(disableAccessFs, ', ') + ')';
    // }
    if (String.isNotBlank(err)) {
      throw new SB_Ot_SObjectConfigException(err);
    }
  }

  // 期日の範囲の条件作成
  @TestVisible
  private String makeDateRangeCondition(Integer dateRange) {
    String result;
    System.assert(dateRange >= 0 && dateRange <= SB_Ot_Global.otConfig.MaxDateRange__c);
    if (dateRange == 0) {
      // 本年 or 本年度
      if (this.otype == SB_Ot_Global.getNameCardSObjectType()) {
        // 名刺： 名刺交換日を指定。名刺管理日なければ、最終更新日を指定
        result = SB_Ot_Global.otConfig.DateRageUseFiscalYear__c ? System.Label.SB_Ot_DateRangeCondition_NC_THISFY : System.Label.SB_Ot_DateRangeCondition_NC_THISCY;
      }
      else {
        result = SB_Ot_Global.otConfig.DateRageUseFiscalYear__c ? System.Label.SB_Ot_DateRangeCondition_THISFY : System.Label.SB_Ot_DateRangeCondition_THISCY;
      }
    }
    else {
      // 複数年
      String cFormat;
      if (this.otype == SB_Ot_Global.getNameCardSObjectType()) {
        // 名刺： 名刺交換日の範囲を指定。名刺管理日なければ、最終更新日の範囲を指定
        // (SmartViscaf__card_exchange_date__c=LAST_N_YEARS:{0} OR SmartViscaf__card_exchange_date__c=THIS_YEAR OR (SmartViscaf__card_exchange_date__c=null AND (LastModifiedDate=LAST_N_YEARS:{0} OR LastModifiedDate=THIS_YEAR)))
        cFormat = SB_Ot_Global.otConfig.DateRageUseFiscalYear__c ? System.Label.SB_Ot_DateRangeCondition_NC_FY : System.Label.SB_Ot_DateRangeCondition_NC_CY;
      }
      else {
        cFormat = SB_Ot_Global.otConfig.DateRageUseFiscalYear__c ? System.Label.SB_Ot_DateRangeCondition_FY : System.Label.SB_Ot_DateRangeCondition_CY;
      }
      result = String.format(cFormat, new String[] { String.valueOf(dateRange)});
    }
    return result;
  }

  @TestVisible
  private List<String> makeConditions(Integer dateRange, String otherCondition) {
    List<String> result = new List<String>();
    // 期日の範囲
    if (dateRange >= 0 && dateRange <= SB_Ot_Global.otConfig.MaxDateRange__c) {
      result.add(makeDateRangeCondition(dateRange));
    }
    // 対象レコードの条件
    if (SB_Ot_Global.isEnableSmartVisca() &&
         (this.otype == Account.getSObjectType() || this.otype == Contact.getSObjectType() || this.otype == Lead.getSObjectType())) {
      // 　アカウント、コンタクト
      if (otherCondition == 'haveNC') {   // 名刺への参照があるレコードのみ
        result.add('SmartViscaf__NameCard__c != null');
      }
      else if (otherCondition == 'haveLatestNC') { // 最新の名刺への参照があるレコードのみ
        result.add('SmartViscaf__NameCard__c != null');
        result.add('(SmartViscaf__NameCard__r.SmartViscaf__Parent__c = null OR SmartViscaf__NameCard__r.SmartViscaf__Saishin__c = true)');
        // result.add('SmartViscaf__NameCard__r.SmartViscaf__Saishin__c != false'); // この名刺が最新
      }
      else if (otherCondition == 'haveNoChangeLatestNC') { // 転職していない最新の名刺への参照があるレコードのみ
        result.add('SmartViscaf__NameCard__c != null');
        result.add('(SmartViscaf__NameCard__r.SmartViscaf__Parent__c = null OR SmartViscaf__NameCard__r.SmartViscaf__Saishin__c = true)');
        result.add('SmartViscaf__NameCard__r.SmartViscaf__tenshokugonomeishi__c = null');
        result.add('SmartViscaf__NameCard__r.SmartViscaf__tenshokuzumi__c != true');
      }
    }
    if (this.otype == Lead.getSObjectType()) {
      result.add(String.format('{0}=:orgName', new String[] { this.orgField }));
      // リードについては、対象レコードの条件 はなしで、
    }
    else if (this.otype == SB_Ot_Global.getNameCardSObjectType()) {
      // 名刺
      result.add(String.format('{0}=:orgName', new String[] { this.orgField }));
      if (otherCondition == 'latest') {
        result.add('(SmartViscaf__Parent__c = null OR SmartViscaf__Saishin__c = true)');
      }
      else if (otherCondition == 'noChangeLatest') {
        result.add('(SmartViscaf__Parent__c = null OR SmartViscaf__Saishin__c = true)');
        result.add('SmartViscaf__tenshokugonomeishi__c = null');
        result.add('SmartViscaf__tenshokuzumi__c != true');
      }
    }
    else if (this.otype == User.getSObjectType()) {
      result.add('Profile.Name!=null');  // Process Automated とか本物のユーザ以外は除く
      // ユーザ
      if (otherCondition == 'active' || otherCondition == 'sameOrgActive') {
        result.add('IsActive = true');
      }
      if (otherCondition == 'sameOrg' || otherCondition == 'sameOrgActive') {
        result.add(String.format('{0} = :orgName', new String[] { this.orgField }));
      }
    }
    return result;
  }

  // private Boolean isMatchDateRange(SObject record) {
  //   // SB_Ot_Global.otConfig.DateRageUseFiscalYear__c 未対応
  //   Integer year = ((Datetime)record.get('LastModifiedDate')).year();
  //   return this.dateRange == 0 || Datetime.now().year() - ((Datetime)record.get('LastModifiedDate')).year() > this.dateRange;
  // }

  // private Boolean isMatchOtherConditions(SObject record) {
  //   if (String.isBlank(this.otherCondition) || this.otherCondition == 'none' || !SB_Ot_Global.isEnableSmartViscaSObject(record.getSObjectType())) {
  //     return true;
  //   }
  //   SObject nc = record.getSObject('SmartViscaf__NameCard__r');
  //   if ((this.otherCondition == 'haveNC' || this.otherCondition == 'haveLatestNC' || this.otherCondition =='haveNoChangeLatestNC') // 名刺への参照があるレコードのみ
  //       && nc == null) {
  //     return false;
  //   }
  //   if ((this.otherCondition == 'haveLatestNC' || this.otherCondition =='haveNoChangeLatestNC') // 最新の名刺への参照があるレコードのみ
  //       && nc.get('SmartViscaf__Parent__c') == null && ((Boolean)nc.get('SmartViscaf__Saishin__c')) != true) {
  //     return false;
  //   }
  //   if (otherCondition == 'haveNoChangeLatestNC'// 転職していない最新の名刺への参照があるレコードのみ
  //        && nc.get('SmartViscaf__tenshokugonomeishi__c') == null && ((Boolean)nc.get('SmartViscaf__tenshokuzumi__c')) != false) {
  //     //  転職してる。
  //     return false;
  //   }
  //   return true;
  // }

  // // 期日の範囲 おいび 対象のオブジェクトの条件に合致してるか
  // public Boolean isMatchDateOtherCpnditions(SObject record) {
  //   return isMatchDateRange(record) && (!SB_Ot_Global.isEnableSmartVisca() || isMatchOtherConditions(record));
  // }
  // User階層で、同一組織だけでないでの、ルートのラベルに組織名を出す
  // 階層の中に会社名を入れる。
  public Boolean isRootLabelUserOrg() {
    return this.otype == User.getSObjectType() && (this.otherCondition == 'none' || this.otherCondition == 'active');
  }

  // グリッドに表示する項目APIs を初期化
  public void setGridFields(List<String> gridFields) {
    this.gridFields.clear();
    this.gridFields.addAll(gridFields);
  }

  public void createLabelFormatter() {
    this.labelFormatter = SB_Ot_LabelFormatter.createLabelFormatter(this);
  }

  private void createDataCreators() {
    this.dataCreators = SB_Ot_LcTreeGridDataCreator.buildCreators(this);
  }

  // Name 項目を中心として表示すラベルを作る
  public String makeLabel(SObject obj) {
    return this.labelFormatter.make(obj);
  }

  private static final Set<Schema.DisplayType> ignoreDisplayTypes = new Set<Schema.DisplayType> {
    Schema.DisplayType.base64,
    Schema.DisplayType.MultiPicklist,
    Schema.DisplayType.EncryptedString,    // 暗号化テキスト
    Schema.DisplayType.TIME    //時刻
  };

  // オブジェクトごとの設定クラスのインスタンス
  @TestVisible
  private static Map<SObjectType, SB_Ot_SObjectConfig> sobj2SObjectConfig = new Map<SObjectType, SB_Ot_SObjectConfig>();

  // ID id = 'a077F000005z4hZQAQ';
  // id.getSObjectType().getDescribe().getName()
  // SObjectConfigを取得    なかったら、サーバの設定 から 生成・取得
  public static SB_Ot_SObjectConfig getSObjectConfig(SObjectType otype) {
    if (sobj2SObjectConfig.containsKey(otype)) {
      return sobj2SObjectConfig.get(otype);
    }
    if (!otype.getDescribe().isAccessible()) {
      throw new SB_Ot_SObjectConfigException('insufficient permission: ' + otype.getDescribe().getLabel());
    }
    SB_Ot_SObjectConfig objConfig;
    if (otype == Account.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(SB_Ot_Global.otConfig.AccountOrgField__c,
                  SB_Ot_Global.otConfig.AccountDivisionField__c,
                  null,
                  null,
                  SB_Ot_Global.otConfig.AccountTreeGridColumns__c,
                  SB_Ot_Global.otConfig.AccountDateRange__c.intValue(),
                  getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.AccountWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype == Contact.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(null,
                  SB_Ot_Global.otConfig.ContactDivisionField__c,
                  SB_Ot_Global.otConfig.ContactTitleField__c,
                  SB_Ot_Global.otConfig.ContactEMailField__c,
                  SB_Ot_Global.otConfig.ContactTreeGridColumns__c,
                  SB_Ot_Global.otConfig.ContactDateRange__c.intValue(),
                  getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.ContactWhere__c,
                  SB_Ot_Global.otConfig.ContactOnlyLatest__c); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype == Lead.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(SB_Ot_Global.otConfig.LeadOrgField__c,
                  SB_Ot_Global.otConfig.LeadDivisionField__c,
                  SB_Ot_Global.otConfig.LeadTitleField__c,
                  SB_Ot_Global.otConfig.LeadEMailField__c,
                  SB_Ot_Global.otConfig.LeadTreeGridColumns__c,
                  0,
                  'none',
                  SB_Ot_Global.otConfig.LeadWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype == User.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(SB_Ot_Global.otConfig.UserOrgField__c,
                  SB_Ot_Global.otConfig.UserDivisionField__c,
                  SB_Ot_Global.otConfig.UserTitleField__c,
                  SB_Ot_Global.otConfig.UserEMailField__c,
                  SB_Ot_Global.otConfig.UserTreeGridColumns__c,
                  -1,
                  getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.UserWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype.getDescribe().getName() == SB_Ot_Global.otConfig.NameCardSObjectName__c) { // NameCardといいつつなんでもいい。
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(SB_Ot_Global.otConfig.NameCardOrgField__c,
                  SB_Ot_Global.otConfig.NameCardDivisionField__c,
                  SB_Ot_Global.otConfig.NameCardTitleField__c,
                  SB_Ot_Global.otConfig.NameCardEMailField__c,
                  SB_Ot_Global.otConfig.NameCardTreeGridColumns__c,
                  SB_Ot_Global.otConfig.NameCardDateRange__c.intValue(),
                  getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.NameCardWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else {
      throw new SB_Ot_SObjectConfigException('Invalid SObjectType');
    }
    sobj2SObjectConfig.put(otype, objConfig);
    return objConfig;
  }

  // クライアントの設定 から SObjectConfigを生成
  //  gridFields=='(none)' はグリッドに名称以外を表示しない
  //  CreateOrgTreeRequest req のなかの targetId は使わず、対象オブジェクトを特定したSObjectType otype を使う
  public static void makeSObjectConfig(SObjectType otype, SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req) {
    // SObjectType otype = req.targetId.getSObjectType();
    if (!otype.getDescribe().isAccessible()) {
      throw new SB_Ot_SObjectConfigException('insufficient permission: ' + otype.getDescribe().getLabel());
    }
    SB_Ot_SObjectConfig objConfig;
    // Account,Contact レコードの場合、Contactに関する設定値になってる
    if (otype == Account.sObjectType || otype == Contact.sObjectType) {
      {
        // アカウントの分は特別扱いで
        SB_Ot_SObjectConfig objCnfig_a = new SB_Ot_SObjectConfig(Account.sObjectType);
        objCnfig_a.init(String.isNotBlank(req.orgField) ? req.orgField : SB_Ot_Global.otConfig.AccountOrgField__c,
                  SB_Ot_Global.otConfig.AccountDivisionField__c,
                  null,
                  null,
                  String.isNotBlank(req.accountGridFields) ? (req.accountGridFields=='(none)' ? null : req.accountGridFields) :
                                              SB_Ot_Global.otConfig.AccountTreeGridColumns__c,
                  req.dateRange != null ? req.dateRange : SB_Ot_Global.otConfig.AccountDateRange__c.intValue(),
                  String.isNotBlank(req.otherCondition) ? req.otherCondition : getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.AccountWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
        sobj2SObjectConfig.put(Account.sObjectType, objCnfig_a);
      }
      objConfig = new SB_Ot_SObjectConfig(Contact.sObjectType);
      objConfig.init(null,
                  String.isNotBlank(req.deptField) ? req.deptField : SB_Ot_Global.otConfig.ContactDivisionField__c,
                  String.isNotBlank(req.titleField) ? req.titleField : SB_Ot_Global.otConfig.ContactTitleField__c,
                  SB_Ot_Global.otConfig.ContactEMailField__c,
                  String.isNotBlank(req.gridFields) ? (req.gridFields=='(none)' ? null : req.gridFields) :
                                                SB_Ot_Global.otConfig.ContactTreeGridColumns__c,
                  req.dateRange != null ? req.dateRange : SB_Ot_Global.otConfig.ContactDateRange__c.intValue(),
                  String.isNotBlank(req.otherCondition) ? req.otherCondition : getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.ContactWhere__c,
                  SB_Ot_Global.otConfig.ContactOnlyLatest__c); //同一内容のレコードでは最新のものだけに絞る
      otype = Contact.sObjectType;
    }
    else if (otype == Lead.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(String.isNotBlank(req.orgField) ? req.orgField : SB_Ot_Global.otConfig.LeadOrgField__c,
                  String.isNotBlank(req.deptField) ? req.deptField : SB_Ot_Global.otConfig.LeadDivisionField__c,
                  String.isNotBlank(req.titleField) ? req.titleField : SB_Ot_Global.otConfig.LeadTitleField__c,
                  SB_Ot_Global.otConfig.LeadEMailField__c,
                  String.isNotBlank(req.gridFields) ? (req.gridFields=='(none)' ? null : req.gridFields) : SB_Ot_Global.otConfig.LeadTreeGridColumns__c,
                  req.dateRange != null ? req.dateRange : SB_Ot_Global.otConfig.LeadDateRange__c.intValue(),
                  String.isNotBlank(req.otherCondition) ? req.otherCondition : getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.LeadWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype == User.sObjectType) {
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(String.isNotBlank(req.orgField) ? req.orgField : SB_Ot_Global.otConfig.UserOrgField__c,
                  String.isNotBlank(req.deptField) ? req.deptField : SB_Ot_Global.otConfig.UserDivisionField__c,
                  String.isNotBlank(req.titleField) ? req.titleField : SB_Ot_Global.otConfig.UserTitleField__c,
                  SB_Ot_Global.otConfig.UserEMailField__c,
                  String.isNotBlank(req.gridFields) ? (req.gridFields=='(none)' ? null : req.gridFields) : SB_Ot_Global.otConfig.UserTreeGridColumns__c,
                  -1,
                  String.isNotBlank(req.otherCondition) ? req.otherCondition : getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.UserWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else if (otype.getDescribe().getName() == SB_Ot_Global.otConfig.NameCardSObjectName__c) { // NameCardといいつつなんでもいい。
      objConfig = new SB_Ot_SObjectConfig(otype);
      objConfig.init(String.isNotBlank(req.orgField) ? req.orgField : SB_Ot_Global.otConfig.NameCardOrgField__c,
                  String.isNotBlank(req.deptField) ? req.deptField : SB_Ot_Global.otConfig.NameCardDivisionField__c,
                  String.isNotBlank(req.titleField) ? req.titleField : SB_Ot_Global.otConfig.NameCardTitleField__c,
                  SB_Ot_Global.otConfig.NameCardEMailField__c,
                  String.isNotBlank(req.gridFields) ? (req.gridFields=='(none)' ? null : req.gridFields) :
                                                    SB_Ot_Global.otConfig.NameCardTreeGridColumns__c,
                  req.dateRange != null ? req.dateRange : SB_Ot_Global.otConfig.NameCardDateRange__c.intValue(),
                  String.isNotBlank(req.otherCondition) ? req.otherCondition : getOtherConditionSetting(otype),
                  SB_Ot_Global.otConfig.NameCardWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
    }
    else {
      throw new SB_Ot_SObjectConfigException('Invalid SObjectType');
    }
    sobj2SObjectConfig.put(otype, objConfig);
  }

  // 取引先の所有者一覧用の設定作成
  public static void makeOwnerListSObjectConfig() {
    // SObjectType otype = req.targetId.getSObjectType();
    if (!Account.sObjectType.getDescribe().isAccessible()) {
      throw new SB_Ot_SObjectConfigException('insufficient permission: ' + Account.sObjectType.getDescribe().getLabel());
    }
    if (!Contact.sObjectType.getDescribe().isAccessible()) {
      throw new SB_Ot_SObjectConfigException('insufficient permission: ' + Contact.sObjectType.getDescribe().getLabel());
    }
    SB_Ot_SObjectConfig objConfig;
    // アカウント
    objConfig = new SB_Ot_SObjectConfig(Account.sObjectType);
    objConfig.init(SB_Ot_Global.otConfig.AccountOrgField__c,
                SB_Ot_Global.otConfig.AccountDivisionField__c,
                null,
                null,
                SB_Ot_Global.otConfig.AccountTreeGridColumns__c,
                SB_Ot_Global.otConfig.OwnerDateRange__c.intValue(),
                getOtherConditionKey(Account.sObjectType, SB_Ot_Global.otConfig.OwnerOtherCondition__c.intValue()),
                SB_Ot_Global.otConfig.OwnerAccountWhere__c,
                false); //同一内容のレコードでは最新のものだけに絞る
    sobj2SObjectConfig.put(Account.sObjectType, objConfig);
    // コンタクト
    objConfig = new SB_Ot_SObjectConfig(Contact.sObjectType);
    objConfig.init(null,
                SB_Ot_Global.otConfig.ContactDivisionField__c,
                SB_Ot_Global.otConfig.ContactTitleField__c,
                SB_Ot_Global.otConfig.ContactEMailField__c,
                SB_Ot_Global.otConfig.ContactTreeGridColumns__c,
                SB_Ot_Global.otConfig.OwnerDateRange__c.intValue(),
                getOtherConditionKey(Contact.sObjectType, SB_Ot_Global.otConfig.OwnerOtherCondition__c.intValue()),
                SB_Ot_Global.otConfig.OwnerContactWhere__c,
                SB_Ot_Global.otConfig.OwnerContactOnlyLatest__c); //同一内容のレコードでは最新のものだけに絞る
      sobj2SObjectConfig.put(Contact.sObjectType, objConfig);
      // ユーザ
      objConfig = new SB_Ot_SObjectConfig(User.sObjectType);
      objConfig.init(SB_Ot_Global.otConfig.UserOrgField__c,
                  SB_Ot_Global.otConfig.UserDivisionField__c,
                  SB_Ot_Global.otConfig.UserTitleField__c,
                  SB_Ot_Global.otConfig.UserEMailField__c,
                  SB_Ot_Global.otConfig.UserTreeGridColumns__c,
                  -1,
                  getOtherConditionSetting(User.sObjectType),
                  SB_Ot_Global.otConfig.UserWhere__c,
                  false); //同一内容のレコードでは最新のものだけに絞る
      sobj2SObjectConfig.put(User.sObjectType, objConfig);
  }
  // // 複数オブジェクトで構成用の設定
  // // カスタム設定のみから構成
  // public static void makeMultiSObjectConfig() {
  //   SB_Ot_SObjectsFiledsParser parser = SB_Ot_SObjectsFiledsParser.getInstance();

  //   for (SObjectType otype : parser.otype2Fields) {
  //     List<String> fList = otype2Fields.get(otype);
  //     List<String> temp = new List<String>();
  //     for (String f : fList) {
  //       if(String.isNotBlank(f)) {
  //         temp.add(f);
  //       }
  //     }
  //     String fields = String.join(temp, ', ');

  //     SObjectConfigBuilder creater;
  //     if (otype == Account.sObjectType) {
  //       creater = new CustomConfigSObjectConfigBuilder(otype);
  //       creater.init(SB_Ot_Global.otConfig.AccountOrgField__c,
  //                   SB_Ot_Global.otConfig.AccountDivisionField__c,
  //                   null,
  //                   null,
  //                   fields,
  //                   SB_Ot_Global.otConfig.AccountWhere__c);
  //     }
  //     else if (otype == Contact.sObjectType) {
  //       creater = new CustomConfigSObjectConfigBuilder(otype);
  //       creater.init(null,
  //                   SB_Ot_Global.otConfig.ContactDivisionField__c,
  //                   SB_Ot_Global.otConfig.ContactTitleField__c,
  //                   SB_Ot_Global.otConfig.ContactEMailField__c,
  //                   fields,
  //                   SB_Ot_Global.otConfig.ContactWhere__c);
  //     }
  //     else if (otype == Lead.sObjectType) {
  //       creater = new CustomConfigSObjectConfigBuilder(otype);
  //       creater.init(SB_Ot_Global.otConfig.LeadOrgField__c,
  //                   SB_Ot_Global.otConfig.LeadDivisionField__c,
  //                   SB_Ot_Global.otConfig.LeadTitleField__c,
  //                   SB_Ot_Global.otConfig.LeadEMailField__c,
  //                   fields,
  //                   SB_Ot_Global.otConfig.LeadWhere__c);
  //     }
  //     else if (otype.getDescribe().getName() == SB_Ot_Global.otConfig.NameCardSObjectName__c) { // NameCardといいつつなんでもいい。
  //       creater = new CustomConfigSObjectConfigBuilder(otype);
  //       creater.init(SB_Ot_Global.otConfig.NameCardOrgField__c,
  //                   SB_Ot_Global.otConfig.NameCardDivisionField__c,
  //                   SB_Ot_Global.otConfig.NameCardTitleField__c,
  //                   SB_Ot_Global.otConfig.NameCardEMailField__c,
  //                   fields,
  //                   SB_Ot_Global.otConfig.NameCardWhere__c);
  //     }
  //     SB_Ot_SObjectConfig result = creater.create();
  //     sobj2SObjectConfig.put(otype, result);
  //   }
  // }


}