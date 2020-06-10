/**
 *
 *  SB_Ot_OrgTreeLcController
 *  Lightning Component による 組織ツリー Lightning Component の Controller
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 0      2017.11.xx v1.22 SV_DEV-412 LEXの組織情報
 *  @Version 1      2018.04.xx OrgTree用
 *  @Version 1.1    2019.05.xx 他オブジェクトへ切替て階層構築可能に、参照項目のオブジェクトで階層構築可能に
 *
 **/
public with sharing class SB_Ot_OrgTreeLcController {
  public with sharing class SB_Ot_OrgTreeLcControllerException extends Exception {}

  private final sObject target;

  public SB_Ot_OrgTreeLcController(ApexPages.StandardController stdController) {
    this.target = (sObject)stdController.getRecord();
  }

  public String getRecordNameAndId() {
      return (String)target.get('name') + ' (' + (Id)target.get('Id') + ')';
  }

  public abstract class Response {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    protected Response() {
      this.success = false;
    }
  }

  // createOrgTree の リクエスト
  public class CreateOrgTreeRequest {
    // @TestVisible public String requestObject { get; public set; } //  表示したいオブジェクト
    @TestVisible public Id selectedId { get; public set; }       // 選択中のレコードID
    @TestVisible public String idField { get; public set; } // v1.1 参照するるレコードIDの項目
    @TestVisible public String displayFormat { get; public set; } // 表示形式
    @TestVisible public Integer dateRange { get; public set; } // 対象レコードの期日の範囲 n年前から
    @TestVisible public String otherCondition { get; public set; } // 対象レコードの条件
    @TestVisible public String orgField { get; public set; }   // 組織名の項目
    @TestVisible public String deptField { get; public set; }  // 部署名の項目
    @TestVisible public String titleField { get; public set; }   // 役職名の項目
    @TestVisible public String gridFields { get; public set; }   // グリッドに表示する項目
    @TestVisible public String deptParser { get; public set; }  // 部門、部署の分割方法
    @TestVisible public Boolean showTitle { get; public set; }  // 役職を表示する
    @TestVisible public Boolean showOwner { get; public set; }   // 所有者を表示する
    @TestVisible public Boolean showEMail { get; public set; }   // メアドを表示する
    @TestVisible public Boolean gridLabelNoExtra { get; public set; }   // グリッドのラベルには 役職等を表示しない
  //  @TestVisible public String labelFormat { get; public set; }
    @TestVisible public Integer maxRecs { get; public set; } //  対象レコード数の制限
    // 取引先 特有の設定項目
    @TestVisible public Boolean accountAssociation { get; public set; } // 親・子の取引先を階層に含める
    @TestVisible public String accountGridFields { get; public set; }   // 取引先 グリッドに表示する項目
    @TestVisible public String accountDeptUsage { get; public set; } // 取引先 部署項目の使用方法
    // v1.1 複数オブジェクト対応
    @TestVisible public Boolean multiObjectActive { get; public set; } // 他オブジェクトによる構成を可能にする
    @TestVisible public String multiObject { get; public set; } // 対象の複数オブジェクト 未使用
    @TestVisible public String multiObjectGridFields { get; public set; } // 対象の複数オブジェクト
    public CreateOrgTreeRequest() {
      this.multiObjectActive = true;
    }
    // 複数のオブジェクトによる構成 ?
    public Boolean isMultiObject() {
      // return this.requestObject == SB_Ot_MultiObjectConfig.MULTI_OBJECT_SYMBOL;
      return false;
    }

  }

  public with sharing class UIConfig {
    @AuraEnabled public Boolean visibleFormatMenu { get; private set; } // v1.1 ユーザの操作不可 処理の継続不可？
    @AuraEnabled public Boolean visibleParserMenu { get; private set; } // v1.1 ユーザの操作不可 処理の継続不可？
    @AuraEnabled public Boolean gridShowNum { get; private set; } // v1.2 グリッドで行番号を表示する showRowNumberColumn
    @AuraEnabled public String appTitle { get; private set; } // v1.1 ユーザの操作不可 処理の継続不可？
    public UIConfig() {
      this.visibleFormatMenu = SB_Ot_Global.otConfig.VisibleFormatMenu__c;
      this.visibleParserMenu = SB_Ot_Global.otConfig.VisibleParserMenu__c;
      this.gridShowNum = SB_Ot_Global.otConfig.GridShowRowNumberColumn__c;
      this.appTitle = System.Label.SB_Ot_AppTitle;
    }
  }

  // createOrgTree の レスポンス
  public with sharing class CreateOrgTreeResponse extends Response {
    @AuraEnabled public Boolean enableOperation { get; private set; } // v1.1 ユーザの操作不可 処理の継続不可？
    // @AuraEnabled public Boolean enableMenu { get; private set; }  // v1.1 ユーザのメニュー操作が可能 falseならメニュー隠す
    @AuraEnabled public UIConfig uiConfig { get; private set; }     // UI関連のカスタム設定
    @AuraEnabled public Id targetId  { get; private set; }     // 対象のレコードID
    // @AuraEnabled public SB_Ot_OrgTreeConfig config  { get; private set; }
    // @AuraEnabled public String rootLabel { get; private set; } // NULL
    @AuraEnabled public List<SB_Ot_OrgTreeItem.Item> items { get; private set; }    // lightning:tree の items で表示する用
    @AuraEnabled public List<String> branchIds { get; private set; } // ブランチノードの識別子 name リスト
    @AuraEnabled public List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> treeGridColumns { get; private set; } // Gridのときだけ
    // v1.1 複数オブジェクト対応
    // @AuraEnabled public Boolean multiObjectActive { get; private set; } //  複数のオブジェクトによる構成  有効？
    private SObjectType sourceSObjectType;      // 階層構築につかったオブジェクトの 複数は null
    @AuraEnabled public String sourceObject { get; private set; } //  階層構築につかったオブジェクト 複数は allObjects
    @AuraEnabled public String summary { get; private set; }
    // @AuraEnabled public List<SB_Ot_MultiObjectConfig.ObjectLabelName> relateObjects  { get; private set; }     // 関連するオブジェクトでツリーを作るためのメニュー用
    //@AuraEnabled public String company  { get; private set; }   // 対象のレコードのName 値
    // @AuraEnabled public boolean mineOnly  { get; private set; }   // 対象のレコードのName 値
    private SB_Ot_OrgTreeConfig config;

    public CreateOrgTreeResponse() {
      super();
      this.enableOperation = true;
      this.uiConfig = new UIConfig();
      // this.enableMenu = true;
    }

    public void build(CreateOrgTreeRequest req) {
      try {
        // SYstem.debug(SB_Ot_Global.allowedLicenses);
        // Schema.SObjectType otype;
        // リクエストから 階層構築の元となるレコードのレコードIDを決める。
        this.targetId = resolveTargetId(req);   // Userオブジェクト指定でない場合、targetId を決める。
        // リクエストから 階層構築につかう オブジェクトを決める。
        Schema.SObjectType sourceSObjectType = resolveSourceSObject();      // 複数は null
        this.sourceObject = sourceSObjectType.getDescribe().getName().toLowerCase();
        // 設定用のインスタンスを作成
        if (!SB_Ot_Global.otConfig.PrioritizeCustomSetting__c) { //
          // リクエストを優先
          this.config = SB_Ot_OrgTreeConfig.getInstance(req);
          SB_Ot_SObjectConfig.makeSObjectConfig(this.targetId.getSobjectType(), req);   // ToDO multiのときこれでいいか？
        }
        else {
          // カスタム設定を優先
          // this.enableMenu = false;
          this.config = SB_Ot_OrgTreeConfig.getInstance();
          this.config.setPageRecordId(req.selectedId);
          this.config.setDisplayFormat(req.displayFormat);
        }
        // 取引先責任者の役割の書式クラスを作成
        if (String.isNotBlank(req.selectedId) && SB_Ot_ContactRoleFormatter.isEnableContactRole(req.selectedId.getSobjectType())) {
          // 選択オブジェクトでの取引先責任者の役割があるオブジェクト用
          SB_Ot_ContactRoleFormatter.createFormatter(req.selectedId.getSobjectType());
        }
        else if (this.targetId.getSobjectType() == Contact.getSObjectType() || this.targetId.getSobjectType() == Account.getSObjectType()) {
          // 取引先責任者のロール値をフォマットするクラスをインスタンス化
          SB_Ot_ContactRoleFormatter.createFormatter(Contact.getSObjectType());
        }

        // if (String.isNotBlank(req.requestObject)) {
        //   // 他オブジェクトで構成 ?
        //   this.sourceObject = req.requestObject.toLowerCase(); // 念の為
        // }
        // else {
        //   this.sourceObject = otype.getDescribe().getName().toLowerCase();    // 小文字で
        // }
        SB_Ot_OrgTreeFactory.OrgItemsFactory factory;
        // レコードを収集してツリーのノードを作るクラス
        factory = SB_Ot_OrgTreeFactory.createOrgItemsFactory(this.targetId, sourceSObjectType, this.config.displayFormat);
        // ツリーのノードを作成
        this.items = factory.create();
        if (this.config.displayFormat == SB_Ot_OrgTreeConfig.ItemDisplayMode.Grid) {
          // Grid
          this.treeGridColumns = SB_Ot_LcTreeGridColumnsCreater.create(sourceSObjectType, factory.hideFields);
          this.branchIds = new List<String>();
          makeBranchIds(this.items);
        }
        // レコード数の表示用
        makeSummary(factory);
        this.success = true;
      }
      catch(Exception e) {
        System.debug(e.getMessage());
        this.success = false;
        this.error = e.getMessage();
      }
    }

    private void makeSummary(SB_Ot_OrgTreeFactory.OrgItemsFactory factory) {
      String summary = ' [' + getSummary(factory.allBranchs, factory.fillStaff, factory.allStaff, this.config.maxRecs) + ']';
      if (this.config.displayFormat == SB_Ot_OrgTreeConfig.ItemDisplayMode.Grid) {
        if (!this.treeGridColumns.isEmpty()) {
          SB_Ot_LcTreeGridColumnsCreater.ColumnData labelCol = this.treeGridColumns.get(0);
          labelCol.label += summary;
        }
      }
      else {
        items.get(0).setLabel(items.get(0).label + summary);
      }
    }

    private String getSummary(Integer b, Integer num, Integer denom, Integer qLimit) {
      List<String> elms = new List<String>();
      if (b != null && b > 0) {
        elms.add(String.valueOf(b) + ' - '); // 取引先数 -
      }
      if (num != null) {
        elms.add(String.valueOf(num));
        if (denom !=null && (num != denom || denom >= qLimit)) {
          elms.add(' / ' + String.valueOf(denom));
        }
        if (denom >= qLimit) {
          elms.add('+');
        }
      }
      return String.join(elms, '');
    }

    // リクエストから 階層構築の元となるレコードのレコードIDを決める。
    // 選択中レコードが参照してるレコードへ 切り替えがあるので。
    private Id resolveTargetId(CreateOrgTreeRequest req) {
      if ((String.isBlank(req.idField) || req.idField == 'id') && String.isNotBlank(req.selectedId)) {
        return req.selectedId;
      }
      else if (String.isBlank(req.selectedId) || req.idField == 'user') {
        return UserInfo.getUserId();
      }
      // ↓ 参照項目のIDから構築するとき
      Schema.DescribeSObjectResult dsr = req.selectedId.getSobjectType().getDescribe();
      Schema.DescribeFieldResult dfr = dsr.fields.getMap().get(req.idField).getDescribe();
      if (dfr == null || dfr.getSOAPType() != Schema.SOAPType.ID) {
        throw new SB_Ot_OrgTreeLcControllerException('Invalid Id Field: ' + req.idField);
      }
      Id selectedId = req.selectedId;
      String query = String.format(QUERY_TARGET_BY_SELECTEDID, new String[] { req.idField, dsr.getName() });
      List<SObject> objs = Database.query(query);
      if (objs.isEmpty()) {
        throw new SB_Ot_OrgTreeLcControllerException('Invalid Operation ');
      }
      Id result = (Id)objs[0].get(req.idField);
      if (result == null) {
        // 参照項目入力なし
        this.enableOperation = false; // ユーザに操作させない
        String oName = dfr.getReferenceTo().isEmpty() ? '' : dfr.getReferenceTo().get(0).getDescribe().getLabel();
        throw new SB_Ot_OrgTreeLcControllerException(
            String.format(Label.SB_Ot_Msg_NoReferenceRecord, new String[] { dfr.getLabel(), oName } ));
      }
      return result;
    }

    // 階層を作るレコードを収集するオブジェクト を判定、返す
    private Schema.SObjectType resolveSourceSObject() {
      System.assert(this.targetId != null);
      SObjectType result;
      // if (this.targetId == null) {
      //   this.sourceObject = 'user';
      //   return User.getSObjectType();
      // }
      // else {
      result = this.targetId.getSobjectType(); // 元レコードと同じ
      // }
      if (result == Contact.getSObjectType()) {
        result = Account.getSObjectType();
      }
      return result;
    }


    // // 階層を作るレコードを収集するオブジェクト
    // // 複数オブジェクトのときはNULL
    // private SObjectType resolveSourceSObject(CreateOrgTreeRequest req) {
    //   SObjectType result;
    //   if (req.requestObject == SB_Ot_MultiObjectConfig.MULTI_OBJECT_SYMBOL) {
    //     result = null; // 複数
    //     this.sourceObject = SB_Ot_MultiObjectConfig.MULTI_OBJECT_SYMBOL;
    //   }
    //   else {
    //     if (req.requestObject == null || this.targetId.getSobjectType().getDescribe().getName() == req.requestObject) {
    //       result = this.targetId.getSobjectType(); // 元レコードと同じ
    //     }
    //     else {
    //       result = Schema.getGlobalDescribe().get(req.requestObject); // 元レコードと別
    //     }
    //     if (result == null) {
    //       throw new SB_Ot_OrgTreeLcControllerException(
    //           String.format('Invalid Request SObject Name: {0}', new String[] { req.requestObject } ));
    //     }
    //     this.sourceObject = result.getDescribe().getName().toLowerCase();
    //     if (this.sourceObject == 'contact') {
    //       this.sourceObject = 'account';
    //     }
    //   }
    //   return result;
    // }

    private void makeBranchIds(List<SB_Ot_OrgTreeItem.Item> items) {
      for (SB_Ot_OrgTreeItem.Item i : Items) {
        if (i.items != null) {
          this.branchIds.add(i.name);
          makeBranchIds(i.items);
        }
      }
    }

  } // class GetOrgTreeItemsResponse

  private static final String QUERY_TARGET_BY_SELECTEDID = 'SELECT Id, {0} FROM {1} WHERE Id = :selectedId';

  /**
  *  lightning:tree の items で表示する用のデータを含むクラスのインスタンスを返す
  *   個別の引数にすると、Integer がうまく渡せないので シリアライズ された 文字列を引数でうけて、デシリアライズ
  *   レスポンスは、シリアライズすると, 要素が多いと Heap Limit 例外になることがあるので、やめる
  **/
  @RemoteAction
  @AuraEnabled(cacheable=true)
  public static CreateOrgTreeResponse createOrgTree(String req) {
    CreateOrgTreeRequest request = (CreateOrgTreeRequest)JSON.deserialize(req, CreateOrgTreeRequest.class);
    CreateOrgTreeResponse result = new CreateOrgTreeResponse();
    //result.build(request.showTitle, request.maxRecs);
    result.build(request);
    return result;
  }

}