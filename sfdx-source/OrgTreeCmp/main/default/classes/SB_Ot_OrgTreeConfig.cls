/**
 *
 *  SB_Ot_OrgTreeConfig
 *    設定情報を保持するクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx OrgTree用
 *
 */
public with sharing class SB_Ot_OrgTreeConfig {

  // //// lightning:treeGrid の カラム
  // public List<SB_Ot_LcColumnDataListCreater.ColumnData> treeGridColumns { get; private set; }

  public enum ItemDisplayMode { Tree, Grid }
  private static Map<String, ItemDisplayMode> MAP_DISPLAYMODE = new Map<String, ItemDisplayMode> {
    'tree' => ItemDisplayMode.Tree,
    'grid' => ItemDisplayMode.Grid
  };
  @TestVisible
  private static ItemDisplayMode getDisplayMode(String text) {
    return MAP_DISPLAYMODE.get(text.toLowerCase());
  }

  // 部署 項目の利用方法 3つ
  public enum DepartmentUsage { Hierarchy,  // 階層にする
                  Label,    // ラベルに追加する
                  None }    // 使用しない
  // cmp から送られてくる値と DepartmentUsage のマップ
  private static Map<String, DepartmentUsage> MAP_DEPTUSAGE = new Map<String, DepartmentUsage> {
    'hierarchy' => DepartmentUsage.Hierarchy,
    'label' => DepartmentUsage.Label,
    'none' => DepartmentUsage.None
  };
  @TestVisible
  private static DepartmentUsage getDepartmentUsage(String text) {
    if (MAP_DEPTUSAGE.containsKey(text.toLowerCase())) {
      return MAP_DEPTUSAGE.get(text.toLowerCase());
    }
    return DepartmentUsage.None;
  }
  // 2020.04.xx v1.4 SV_ORGTREE-20 カスタム設定「取引先: 部署名の項目の利用方法 」の初期値を 0:使用しない にする。
  // 1と2を入れ替える
  private static DepartmentUsage getDepartmentUsage(Integer num) {
    switch on num {
      when 1 {          // v1.4 でラベルは 1
        return DepartmentUsage.Label;   // ラ
      }
      when 2 {          // v1.4 で 2が階層化
        return DepartmentUsage.Hierarchy; // 階層化 未サポート
      }
      when else {
        return DepartmentUsage.None;
      }
    }
  }

  // 部門、部署項目を階層に使う場合の部署の分割方法。
  public enum DepartmentParser { Separator,  // 空白で区切って階層化する。ただし、英数字のみの語は他に連結する。区切ったノード名で長さ比較する(OrderBYしておく)
                              Line,     // 改行で分ける
                              Comparision,   // OrderBYしておいて、前レコードと比較して長い部分を階層化する。
                              Regex,      // 正規表現
                              Noop }      // 部署項目の値を分割しないでそのまま使う

  private static Map<String, DepartmentParser> MAP_DEPTPARSER = new Map<String, DepartmentParser> {
    'separator' => DepartmentParser.Separator,
    'line' => DepartmentParser.Line,
    'comparision' => DepartmentParser.Comparision,
    'regex' => DepartmentParser.Regex,
    'noop' => DepartmentParser.Noop
  };

  @TestVisible
  private static DepartmentParser getDepartmentParser(String text) {
    if (MAP_DEPTPARSER.containsKey(text.toLowerCase())) {
      return MAP_DEPTPARSER.get(text.toLowerCase());
    }
    return DepartmentParser.Separator;
  }

  @TestVisible
  private static DepartmentParser getDepartmentParser(Integer num) {
    switch on num {
      when 1 {
        return DepartmentParser.Line;
      }
      when 2 {
        return DepartmentParser.Comparision;
      }
      when 3 {
        return DepartmentParser.Regex;
      }
      when 4 {
        return DepartmentParser.Noop;
      }
      when else { // 0 アップビルダー、カスタム設定 のデフォルト
        return DepartmentParser.Separator;
      }
    }
  }

  // 他オブジェクトを関連づけるときに用いる項目
  // 0: 会社名 (会社名が一致するレコードを探す）
  // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
  // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
  public enum ConectionMethod {
    OrgName,    // 会社名
    Email,  // メールアドレス
    SvReference   // 名刺レコードの参照項目
  }
  @TestVisible
  private static ConectionMethod getConectionMethod(Integer num) {
    switch on num {
      when 1 {
        return ConectionMethod.Email;
      }
      when 2 {
        return ConectionMethod.SvReference;
      }
      when else {
        return ConectionMethod.OrgName;
      }
    }
  }

  // クライアントからもリクエストされる設定値
  public Id pageRecordId { get; private set; } // 配置したレコードページのレコードID レコード詳細ページでなければ NULL
  @TestVisible public ItemDisplayMode displayFormat { get; private set; }
  @TestVisible public DepartmentParser deptParser { get; private set; }  // 部門、部署の分割方法
  @TestVisible public Boolean showTitle { get; private set; }  // ラベルに役職を表示する
  @TestVisible public Boolean showOwner { get; private set; }   // ラベルに所有者を表示する
  @TestVisible public Boolean showEMail { get; private set; }   // ラベルにメアドを表示する
  @TestVisible public Boolean showSObject { get; private set; }  // v1.1 ラベルに オブジェクト識別名 を 表示する 複数オブジェクト向け
  @TestVisible public Boolean gridLabelNoExtra { get; private set; }  // グリッドのラベルには 役職等を表示しない
  public Integer maxRecs { get; private set; } //  対象レコード数の制限
  // 取引先 特有の設定項目
  public Boolean accountAssociation { get; private set; } // 階層に関連会社を含める
  public DepartmentUsage accountDeptUsage { get; private set; } // 取引先 部署項目の使用方法
  // サーバでのみ保持する設定値
  public Boolean mineOnly { get; private set; }
  public Boolean selectedMark { get; private set; }   // 選択中のレコードに印 をつける。
  public Boolean yourRecordMark { get; private set; }   // 自分が所有するレコードに 印 をつける
  public Boolean multiObjectActive { get; private set; }      // v1.1 複数のオブジェクトによる構成  有効？
  public ConectionMethod multiConnectionMethod  { get; private set; } // v1.1 5.複数オブジェクトの紐づけ項目
  public String multiObject { get; private set; } // 　複数オブジェクトで扱うオブジェクト文字列、カンマ区切り
  public String multiObjectGridFields { get; private set; } // 　複数オブジェクトで扱うオブジェクトの項目、カンマ区切り
  // public SB_Ot_MultiObjectConfig multiConfig { get; private set; } // 複数オブジェクト対応の設定
  // private SB_Ot_ContactRoleFormatter.ContactRoleFormatter contactRoleFormatter;

  public void setDisplayFormat(String text) {
    this.displayFormat = getDisplayMode(text);
  }
  public void setDeptParser(Integer n) {
    this.deptParser = getDepartmentParser(n);
  }
  public void setAccountAssociation(Boolean b) {
    this.accountAssociation = b;
  }
  public void setPageRecordId(Id recId) {
    this.pageRecordId = recId;
  }

  // public void setShowOwner(Boolean b) {
  //   this.showOwner = b;
  // }
  public SB_Ot_OrgTreeConfig() {
    this.displayFormat = ItemDisplayMode.Grid;
    this.deptParser = getDepartmentParser((Integer)SB_Ot_Global.otConfig.DepartmentParser__c);    // 階層時の 部門、部署の 分割方法
    this.showTitle = true;
    this.showOwner = true;
    this.showEMail = false;
    this.showSObject = false;
    this.gridLabelNoExtra = SB_Ot_Global.otConfig.NameOnlyInGrid__c;   // グリッドでは氏名のみ;
    this.maxRecs = (Integer)SB_Ot_Global.otConfig.MaxRecords__c;
    this.accountAssociation = SB_Ot_Global.otConfig.AccountAssociation__c;    // 取引先 親・子の取引先を階層に含める
    this.accountDeptUsage = getDepartmentUsage((Integer)SB_Ot_Global.otConfig.AccountDepartmentUsage__c); // 取引先 部署項目の使用方法
    this.mineOnly = false;
    this.selectedMark = SB_Ot_Global.otConfig.EnableSelectedRecordMark__c;
    this.yourRecordMark = SB_Ot_Global.otConfig.EnableYourRecordMark__c;
    this.multiObjectActive = SB_Ot_Global.otConfig.MultiObjectActive__c;
    this.multiConnectionMethod = getConectionMethod((Integer)SB_Ot_Global.otConfig.MultiObjectConnectionField__c);  // 5.複数オブジェクトの紐づけ項目
    this.multiObject = SB_Ot_Global.otConfig.MultiObject__c; // 　複数オブジェクトで扱うオブジェクト文字列、カンマ区切り
    this.multiObjectGridFields = SB_Ot_Global.otConfig.MultiObjectTreeGridColumns1__c; // 　複数オブジェクトで扱うオブジェクトの項目、カンマ区切り
    if (String.isNotBlank(SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c)) {
      this.multiObjectGridFields += SB_Ot_Global.otConfig.MultiObjectTreeGridColumns2__c;
    }
    // v1.1 別オブジェクトのレコード詳細でコンタクトを出す用
    this.pageRecordId = null;  // 別のレコード詳細
    // this.contactRoleFormatter = SB_Ot_ContactRoleFormatter.createFormatter(Contact.getSObjectType());
    SB_Ot_ContactRoleFormatter.createFormatter(Contact.getSObjectType());
  }

  public SB_Ot_OrgTreeConfig(SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req) {
    this.displayFormat = String.isNotBlank(req.displayFormat) ? getDisplayMode(req.displayFormat) : ItemDisplayMode.Grid;
    this.deptParser = String.isNotBlank(req.deptParser) ?
          getDepartmentParser(req.deptParser) :
          getDepartmentParser((Integer)SB_Ot_Global.otConfig.DepartmentParser__c);       // 部門、部署の分割方法
    this.showTitle = req.showTitle != null ? req.showTitle : SB_Ot_Global.otConfig.NameWithTitle__c;       // 役職を表示する
    this.showOwner = req.showOwner != null ? req.showOwner : SB_Ot_Global.otConfig.NameWithOwner__c;        // 所有者を表示する
    this.showEMail = req.showEMail != null ? req.showEMail : SB_Ot_Global.otConfig.NameWithEmail__c;        // メアドを表示する
    this.gridLabelNoExtra = req.gridLabelNoExtra != null ? req.gridLabelNoExtra : SB_Ot_Global.otConfig.NameOnlyInGrid__c;   // グリッドでは氏名のみ
    this.showSObject = req.isMultiObject() ? true : false; // v1.1 ラベルに オブジェクト識別名 を 表示する 複数オブジェクト向け
    this.maxRecs = req.maxRecs != null ? req.maxRecs : (Integer)SB_Ot_Global.otConfig.MaxRecords__c;      //  対象レコード数の制限
    this.accountAssociation = req.accountAssociation != null ?
          req.accountAssociation : SB_Ot_Global.otConfig.AccountAssociation__c; // 取引先 親・子の取引先を階層に含める
    this.accountDeptUsage = String.isNotBlank(req.accountDeptUsage) ?
          getDepartmentUsage(req.accountDeptUsage) :
          getDepartmentUsage((Integer)SB_Ot_Global.otConfig.AccountDepartmentUsage__c); // 取引先 部署項目の使用方法
    this.mineOnly = false;
    this.selectedMark = SB_Ot_Global.otConfig.EnableSelectedRecordMark__c;
    this.yourRecordMark = SB_Ot_Global.otConfig.EnableYourRecordMark__c;
    this.multiObjectActive = req.multiObjectActive;
    this.multiConnectionMethod = getConectionMethod((Integer)SB_Ot_Global.otConfig.MultiObjectConnectionField__c);  // 5.複数オブジェクトの紐づけ項目
    this.multiObject = String.isNotBlank(req.multiObject) ? req.multiObject : SB_Ot_Global.otConfig.MultiObject__c; // 　複数オブジェクトで扱うオブジェクト文字列、カンマ区切り
    this.multiObjectGridFields = String.isNotBlank(req.multiObjectGridFields) ?
            req.multiObjectGridFields : SB_Ot_Global.otConfig.MultiObjectTreeGridColumns1__c; // 　複数オブジェクトで扱うオブジェクトの項目、カンマ区切り
    // if (this.multiObjectActive) {
    //   // 混乱するとあれなので、プロパティには持たず初期化だけ
    //   SB_Ot_MultiObjectConfig multiConfig = SB_Ot_MultiObjectConfig.getInstance(req.multiObject, req.multiObjectGridFields);
    // }
    // v1.1 別オブジェクトのレコード詳細でコンタクトを出す用
    this.pageRecordId = req.selectedId;
    // this.contactRoleFormatter = SB_Ot_ContactRoleFormatter.createFormatter(this.pageRecordId.getSObjectType());
  }

  private static SB_Ot_OrgTreeConfig instance;

  // カスタム設定だけから設定
  public static SB_Ot_OrgTreeConfig getInstance() {
    if (instance == null) {
      instance = new SB_Ot_OrgTreeConfig();
    }
    return instance;
  }

  // AppBuilderの設定も加えて設定
  public static SB_Ot_OrgTreeConfig getInstance(SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req) {
    if (instance == null) {
      instance = new SB_Ot_OrgTreeConfig(req);
    }
    return instance;
  }

}