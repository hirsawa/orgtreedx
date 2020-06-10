/**
 * SB_Ot_MultiObjectConfig
 *    複数オブジェクトで構成する場合の設定文字列をパースして、対象のオブジェクトと、オブジェクトごとの項目を得る
 *      Acount, Contact は2つ1組 どちらかの指定があれば Account で識別する。
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 初版 複数オブジェクト構成対応
 *
 **/
public with sharing class SB_Ot_MultiObjectConfig {
  public class SB_Ot_MultiObjectConfigException extends Exception {}

  public static final String MULTI_OBJECT_SYMBOL = 'multiObject';

  private static Map<String, SObjectType> OBJNAME2OTYPE = new Map<String, SObjectType> {
    'account' => Account.sObjectType,
    // 'contact' => Contact.sObjectType,  // Contact なら account で調べる Account とせっとで識別
    'lead' => Lead.sObjectType
  };
  // なるたけ、Schema.getGlobalDescribe() を使わずに 文字列 ⇛ SObjectType 変換
  public static SObjectType getSObjectType(String objName) {
    SObjectType result = OBJNAME2OTYPE.get(objName.toLowerCase());
    if (result == null) {// } && objName == 'smartviscaf__namecard__c') {
      result = Schema.getGlobalDescribe().get(objName);
    }
    return result;
  }

  public with sharing class SpecialColumn {
    public String id { get; private set; }
    public String title { get; private set; }
    public SpecialColumn(String id, String title) {
      this.id = id;
      this.title = title;
    }
  }

  public static Map<String, SpecialColumn> SPECIAL_COLUMNS = new Map<String, SpecialColumn> {
    'sobject' => new SpecialColumn('sobject', System.Label.SB_Ot_Text_SObjectColumnTitle),
    'sobjectIcon' => new SpecialColumn('sobjectIcon', System.Label.SB_Ot_Text_SObjectColumnTitle)
  };

  // 項目API 名を 読み替える名刺の項目
  private static Map<String, String> STD_FIELD2SV_FIELD = new Map<String, String> {
    'firstname' => 'firstname', // 特別扱い
    'lastname' => 'lastname', // 特別扱い
    'department' => 'smartviscaf__division__c', // 所属
    'title' => 'smartviscaf__title_name__c',
    'phone' => 'smartviscaf__tel1__c',
    'fax' => 'smartviscaf__fax1__c',
    'email' => 'smartviscaf__email__c',
    'website' => 'smartviscaf__web_url1__c',
    'mobilephone' => 'smartviscaf__mobile__c'
    // 'AddresPrefacture' => SmartViscaf__address_pref__c,
    // 'postalcode' => 'SmartViscaf__zip_code__c'
  };

  public class ObjectLabelName {
    @AuraEnabled public String label { get; private set; }
    @AuraEnabled public String name { get; private set; }
    @AuraEnabled public String icon { get; private set; }
    public ObjectLabelName(List<String> labels) {
      this.label =  String.join(labels, ', ');
      this.name = MULTI_OBJECT_SYMBOL;           // 指定の全部オブジェクトで構成 識別子
      this.icon =  'standard:record';
    }
    public ObjectLabelName(SObjectType otype) {
      Schema.DescribeSObjectResult dsr = otype.getDescribe();
      if (otype != Account.getSObjectType()) {
        this.label = dsr.getLabel();
        this.name = dsr.getName().toLowerCase();  // 小文字にする。識別用
        this.icon =  'standard:' + dsr.getName().toLowerCase();
      }
      else {
        // Account と Contact 用
        this.label = String.format('{0}, {1}', new String[] { dsr.getLabel(), Contact.getSObjectType().getDescribe().getLabel() });
        this.name = dsr.getName().toLowerCase();  // 小文字にする。識別用
        this.icon =  'standard:person_account'; //  + dsr.getName().toLowerCase();
      }
    }
  }

  // @TestVisible public List<String> oNames { get; private set; }
  // @TestVisible public List<SObjectType> oTypes { get; private set; }
  @TestVisible public Map<String, SObjectType> oName2Types { get; private set; }
  @TestVisible public Map<SObjectType, List<String>> otype2Fields { get; private set; }
  @TestVisible public List<ObjectLabelName> objects { get; private set; }
  @TestVisible public List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> gridColumns { get; private set; }

  // オブジェクトの識別子から対象のSObjectType のコレクションを返す。
  //  sourceObject: NULLもある
  //  戻り: からもある。
  public List<SObjectType> getSObjectTypeList(String sourceObject) {
    List<SObjectType> result = new List<SObjectType>();
    if (sourceObject == MULTI_OBJECT_SYMBOL) {
      result.addAll(oName2Types.values());
    }
    else if (oName2Types.containsKey(sourceObject)) {
      result.add(oName2Types.get(sourceObject.toLowerCase()));
    }
    return result;
  }

  private SB_Ot_MultiObjectConfig(String objs, String cols) {
    // this.oNames = new List<String>();
    // this.oTypes = new List<SObjectType>();
    this.oName2Types = new Map<String, SObjectType>();
    this.otype2Fields = new Map<SObjectType, List<String>>();
    this.objects = new List<ObjectLabelName>();
    this.gridColumns = null;
    init(objs, cols);
  }

  private void init(String objs, String cols) {
    if (String.isBlank(objs)) {
      throw new SB_Ot_MultiObjectConfigException('Blank Object Names');
    }
    if (String.isBlank(cols)) {
      throw new SB_Ot_MultiObjectConfigException('Blank Field Names');
    }
    makeObjectsList(objs);
    makeFieldsList(cols);
    // makeGirdColumns();
  }

  private void makeObjectsList(String objs) {
    // this.oNames.clear();
    // this.oTypes.clear();
    this.oName2Types.clear();
    this.objects.clear();
    String[] oo = objs.toLowerCase().split(',\\s*'); // 小文字で 分割
    for (String o : oo) {
      SObjectType otype = getSObjectType(o);
      // SObjectType otype = OBJNAME2OTYPE.get(o.toLowerCase());
      // if (otype == null) {
      //   otype = Schema.getGlobalDescribe().get(o);
        if (otype == null) {
          if (o == 'smartviscaf__namecard__c') {
            // 名刺がなかったならスルーする。
            continue;
          }
          else {
            throw new SB_Ot_MultiObjectConfigException('Invalid Object API Name: ' + o);
          }
        }
      // }
      // オブジェクトに関するリスト、マップを追加
      addObjectType(o, otype);
    }
    // // どちらかしかなかったら、詰める
    adjustAccountContact();
    if (!this.objects.isEmpty()) {
      // 有効なら 全部オブジェクト マージ を追加
      List<String> objLabels = new List<String>();
      for (ObjectLabelName o : this.objects) {
        objLabels.add(o.label);
      }
      this.objects.add(new ObjectLabelName(objLabels));
    }
  }

  // オブジェクトに関するリスト、マップを追加
  private void addObjectType(String oname, SObjectType otype) {
    // this.oNames.add(oname.toLowerCase());
    // this.oTypes.add(otype);
    this.oName2Types.put(oname, otype);
    if (otype != Contact.getSObjectType()) {
      //  コンタクトではいれない。
      this.objects.add(new ObjectLabelName(otype));
    }
  }

  // どちらかしかなかったら、足しとく
  private void adjustAccountContact() {
    if (otype2Fields.containsKey(Account.sObjectType) && !otype2Fields.containsKey(Contact.sObjectType)) {
      //コンタクトを詰める
      addObjectType('contact', Contact.sObjectType);
    }
    else if (!otype2Fields.containsKey(Account.sObjectType) && otype2Fields.containsKey(Contact.sObjectType)) {
      // アカウントを
      addObjectType('account', Account.sObjectType);
    }
  }

  // オブジェクトごとのグリットの列に入る項目API名を取得
  // 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId'
  //  あるいは、ある列について、オブジェクトAPI名.項目API名;オブジェクトAPI名.項目API名;オブジェクトAPI名.項目API名
  //      例 Contact.Email; Lead.Email; SmartViscaf__NameCard__c.SmartViscaf__email__c のようにようにならべるのも可能
  private void makeFieldsList(String input) {
    this.otype2Fields.clear();
    String[] cols = input.toLowerCase().split(',\\s*');  // 小文字にしとく
    for (String objName : this.oName2Types.keySet()) { // オブジェクト単位に処理
      SObjectType otype = this.oName2Types.get(objName);
      Map<String, Schema.SObjectField> fMap = otype.getDescribe().fields.getMap();
      List<String> fields = new List<String>();
      for (Integer n=0; n < cols.size(); n++) {
        String validF = null;
        System.debug(cols.get(n));
        String[] ff = cols.get(n).split(';\\s*');
        for (String f : ff) {
          System.debug(f);
          String[] ss = f.trim().split('\\.');
          if (ss.size() == 1 && (fMap.containsKey(ss[0]) || SPECIAL_COLUMNS.containsKey(ss[0]))) {
            validF = ss[0];
          }
          else if (ss.size() == 2 && ss[0] == objName && fMap.containsKey(ss[1])) {
            validF = ss[1];
          }
          else if (ss.size() == 1 && objName == 'smartviscaf__namecard__c' && STD_FIELD2SV_FIELD.containsKey(ss[0])) {
            // 標準の項目API名を 名刺の項目API名に置き換える。
            validF = STD_FIELD2SV_FIELD.get(ss[0]);
          }
        }
        fields.add(validF);  // nullでも入れる ⇢ 全オブジェクトでNULLの場合、あとでカラム定義をつくったとき抜く
      }
      this.otype2Fields.put(otype, fields);
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
      // オブジェクトごとの設定 を更新 グリッドに表示する項目APIs を初期化
      System.debug(LoggingLevel.INFO, 'makeFieldsList:' + fields);
      sobjConfig.setGridFields(fields);
    }
  }

  private void makeGirdColumns() {
    for (SObjectType otype : otype2Fields.keySet()) {
      List<String> fields = otype2Fields.get(otype);
      this.gridColumns = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(this.gridColumns, fields, otype);
    }
  }

  private static SB_Ot_MultiObjectConfig instance;

  public static SB_Ot_MultiObjectConfig getInstance() {
    if (instance == null) {
      SB_Ot_OrgTreeConfig treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      String columns = SB_Ot_Global.otConfig.MultiObjectTreeGridColumns1__c;
      if (String.isNotBlank(SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c)) {
        columns += SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c;
      }
      instance = new SB_Ot_MultiObjectConfig(treeConfig.multiObject, treeConfig.multiObjectGridFields);
    }
    return instance;
  }

  // // AppBuilderの設定から作るとき
  // // String objs 対象のオブジェクト カンマ区切り,  NULLなら カスタム設定から
  // // String cols  対象の項目、カンマ区切りと,;で...   NULLなら カスタム設定から
  // public static SB_Ot_MultiObjectConfig getInstance(String objs, String cols) {
  //   if (instance == null) {
  //     String objects = SB_Ot_Global.otConfig.MultiObject__c;
  //     String columns = SB_Ot_Global.otConfig.MultiObjectTreeGridColumns1__c;
  //     if (String.isNotBlank(SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c)) {
  //       columns += SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c;
  //     }
  //     if (String.isNotBlank(objs)) {
  //       objects = objs;
  //     }
  //     if (String.isNotBlank(cols)) {
  //       columns = cols;
  //     }
  //     instance = new SB_Ot_MultiObjectConfig(objects, columns);
  //   }
  //   return instance;
  // }
}