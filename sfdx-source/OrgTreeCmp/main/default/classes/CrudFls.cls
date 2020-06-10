public with sharing class CrudFls {
  public class CrudFlsException extends exception {}



  // CRDU FLS チェック付き 作成
  public static List<Database.SaveResult> screate(List<SObject> os, Boolean allOrNone) {
    System.assert(os != null && !os.isEmpty());

    Schema.DescribeSObjectResult descSObj = os[0].getSObjectType().getDescribe();
    // オブジェクト作成権限があるか
    if (!descSObj.isCreateable()) {
      throw new CrudFlsException(String.format('{0} オブジェクトの作成権限がありません。', new String[] {descSObj.label}));
    }

    Map<string, Schema.SObjectField> fieldMap = descSObj.fields.getMap();
    Set<String> fields = getCheckFields(os);    // 入力のあった項目s
    // 入力のあった項目が作成可能でないと例外
    for (String field : fields) {
      Schema.DescribeFieldResult descField = fieldMap.get(field).getDescribe();
      if (descField.getType() != DisplayType.location        // Location 型は isCreateable() とかでエラーになる。
        && descField.isPermissionable()           // 権限設定出来る項目だけ
        && descField.isCreateable() == false      // 作成可能?
        && descField.isAutoNumber() == false      // 自動採番?
        && descField.isCalculated() == false) {   // 数式?
          throw new CrudFlsException(String.format('{0} オブジェクトの項目 {1} ({2}) の作成権限がありません。',
                                    new String[] {descSObj.label, descField.getLabel(), descField.getName()}));
      }
    }
    // DMLオプション
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = allOrNone;
    // DML結果
    List<Database.SaveResult> sr;
    try {
      // INSERT
      sr = Database.insert(os, dml);
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format('{0} レコード 作成エラー : {1}',
                                new String[]{ descSObj.label, e.getMessage() }));
    }
    return sr;
  }

  // 更新
  public static List<Database.SaveResult> supdate(List<SObject> os, Boolean allOrNone) {
    System.assert(os != null && !os.isEmpty());

    Schema.DescribeSObjectResult descSObj = os[0].getSObjectType().getDescribe();
    // オブジェクトの編集権限があるか
    if (!descSObj.isUpdateable()) {
      throw new CrudFlsException(String.format('{0} オブジェクトの更新権限がありません。', new String[] {descSObj.label}));
    }

    Map<string, Schema.SObjectField> fieldMap = descSObj.fields.getMap();
    Set<String> fields = getCheckFields(os);    // 入力のあった項目s
    // 入力のあった項目が編集可能でないと例外
    for (String field : fields) {
      Schema.DescribeFieldResult descField = fieldMap.get(field).getDescribe();
      if (descField.getType() != DisplayType.location         // Location 型は isCreateable() とかでエラーになる。
        && descField.isPermissionable()       // 権限設定出来る項目だけ
        && descField.isUpdateable() == false      // 更新可能？
        && descField.isAutoNumber() == false      // 自動採番?
        && descField.isCalculated() == false) {   // 数式?
          throw new CrudFlsException(String.format('{0} オブジェクトの項目 {1} ({2}) の更新権限がありません。',
                                    new String[] {descSObj.label, descField.getLabel(), descField.getName()}));
      }
    }
    // DMLオプション
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = allOrNone;
    List<Database.SaveResult> sr;
    try {
      sr = Database.update(os, dml);
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format('{0} レコード 更新エラー : {1}',
                                new String[]{ descSObj.label, e.getMessage() }));
    }
    return sr;
  }

  //オブジェクトを削除
  public static List<Database.DeleteResult> sdelete(List<SObject> os) {
    System.assert(os != null && !os.isEmpty());

    Schema.DescribeSObjectResult descSObj = os[0].getSObjectType().getDescribe();
    // オブジェクトの削除権限があるか
    if (!descSObj.isDeletable()) {
        throw new CrudFlsException(String.format('0} オブジェクトの削除権限がありません。', new String[] {descSObj.label}));
    }
    List<Database.DeleteResult> sr;
    try {
      sr = Database.delete(os);
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format('{0} レコード 削除エラー : {1}',
                                new String[]{ descSObj.label, e.getMessage() }));
    }
    return sr;
  }

  // 入力のあった項目API名を抽出する。
  @TestVisible
  private static Set<String> getCheckFields(List<SObject> os) {
    Set<String> result = new Set<String>();
    for (SObject o : os) {
      result.addAll(o.getPopulatedFieldsAsMap().keySet());
    }
    return result;
  }

}