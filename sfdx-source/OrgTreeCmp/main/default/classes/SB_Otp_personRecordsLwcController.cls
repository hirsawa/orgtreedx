public with sharing class SB_Otp_personRecordsLwcController {

  @AuraEnabled(cacheable=true)
  public static SB_Otp_PersonRecordsBuilder.GetPersonRecordsResponse getPersonRecords(
      Id targetId, // アカウント or コンタクト のレコードID
      String otherObjects,  // 対象のオブジェクト
      String collateFields,   // 照合する項目
      String sortField,   // 並び替え項目
      String sortOrder,   // 並び替え順
      String tableFields, // 表示項目
      Integer pageSize) { // ページサイズ

    SB_Otp_PersonRecordsBuilder builder = new SB_Otp_PersonRecordsBuilder(
      targetId, // アカウント or コンタクト のレコードID
      otherObjects,  // 対象のオブジェクト
      collateFields,   // 照合する項目
      sortField,   // 並び替え;目
      sortOrder, // 並び替え順
      tableFields, // 表示項目
      pageSize);  // ページサイズ
    return builder.create();
  }



}