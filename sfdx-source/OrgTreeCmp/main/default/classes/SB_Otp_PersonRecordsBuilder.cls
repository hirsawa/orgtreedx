public with sharing class SB_Otp_PersonRecordsBuilder {

  public abstract class LwcResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String message { get; private set; }

    public LwcResponse() {
      this.success = true;
    }
    public void setException(Exception e) {
      this.message = e.getMessage();
      this.success = false;
    }
  }

  public with sharing class UIConfig {
    @AuraEnabled public Boolean showRefreshMenu  { get; private set; } // 調合項目のチェックボックスの更新ボタンを表示する
    @AuraEnabled public Boolean showRowNum { get; private set; } // v1.2 グリッドで行番号を表示する showRowNumberColumn
    @AuraEnabled public String appTitle { get; private set; } // v1.1 ユーザの操作不可 処理の継続不可？
    public UIConfig() {
      this.showRefreshMenu = true;
      this.showRowNum = true;
      this.appTitle = 'Personal Mountains';
    }
  }

  public with sharing class GetPersonRecordsResponse extends LwcResponse {
    @AuraEnabled public UIConfig uiConfig { get; private set; }     // UI関連のカスタム設定
    @AuraEnabled public String targetId { get; private set; }
    @AuraEnabled public List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> treeGridColumns { get; private set; } // カラムの設定
    @AuraEnabled public List<SB_Otp_PersonRecord> records { get; private set; }
    @AuraEnabled public List<Id> recordIds { get; private set; }
    private GetPersonRecordsRequest req;
    private GetPersonRecordsResponse(GetPersonRecordsRequest req) {
      this.req = req;
    }
    public void build() {}
  }

  public with sharing class GetPersonRecordsRequest {
    private Id targetId; // アカウント or コンタクト のレコードID
    private String otherObjects;  // 対象のオブジェクト
    private String collateFields;   // 照合する項目
    private String sortField;   // 並び替え項目
    private String sortOrder;   // 並び替え順
    private String tableFields; // 表示項目

    public GetPersonRecordsRequest(
      Id targetId, // アカウント or コンタクト のレコードID
      String otherObjects,  // 対象のオブジェクト
      String collateFields,   // 照合する項目
      String sortField,   // 並び替え;目
      String sortOrder, // 並び替え順
      String tableFields, // 表示項目
      Integer pageSize) { // ページサイズ

        this.targetId = targetId; // アカウント or コンタクト のレコードID
        this.otherObjects = otherObjects;  // 対象のオブジェクト
        this.collateFields = collateFields;   // 照合する項目
        this.sortField = sortField;   // 並び替え項目
        this.sortOrder = sortOrder;   // 並び替え順
        this.tableFields = tableFields; // 表示項目
    }

  }

  private GetPersonRecordsRequest request;

  public SB_Otp_PersonRecordsBuilder (
    Id targetId, // アカウント or コンタクト のレコードID
    String otherObjects,  // 対象のオブジェクト
    String collateFields,   // 照合する項目
    String sortField,   // 並び替え;目
    String sortOrder, // 並び替え順
    String tableFields, // 表示項目
    Integer pageSize) { // ページサイズ


    this.request = new GetPersonRecordsRequest(
      targetId,
      otherObjects,  // 対象のオブジェクト
      collateFields,   // 照合する項目
      sortField,   // 並び替え;目
      sortOrder, // 並び替え順
      tableFields, // 表示項目
      pageSize);  // ページサイズ
  }

  public GetPersonRecordsResponse create() {
    GetPersonRecordsResponse result = new GetPersonRecordsResponse(this.request);
    result.build();
    return result;
  }

}