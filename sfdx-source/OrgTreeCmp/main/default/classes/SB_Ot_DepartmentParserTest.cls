@isTest
private class SB_Ot_DepartmentParserTest {


  @isTest
  static void test_NoopParser1() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Noop);
    List<String> branchs;
    //
    branchs = parser.parse('World Webmaster 営業本部 第1課', new List<String> { 'World Webmaster IAマーケティング本部 MK企画室' });
    System.assertEquals(1, branchs.size());
    System.assertEquals('World Webmaster 営業本部 第1課', branchs[0]);

  }


  @isTest
  static void test_SeparaterParser_DividedJ() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Separator);
    List<String> branchs;
    //
    branchs = parser.parse('World Webmaster 営業本部 第1課', new List<String> { 'World Webmaster IAマーケティング本部', 'MK企画室' });
    System.assertEquals(2, branchs.size());
    System.assertEquals('World Webmaster 営業本部', branchs[0]);
    System.assertEquals('第1課', branchs[1]);
  }

  @isTest
  static void test_SeparaterParser_AaddB() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Separator);
    List<String> previous = new List<String> { '社長室' };
    List<String> branchs;
    // 英語 で 兼 がはいってる。 ないだろうけど
    branchs = parser.parse('Sales Dept. 兼 Dev. Dept.', previous);
    System.assertEquals(1, branchs.size());
    System.assertEquals('Sales Dept. 兼 Dev. Dept.', branchs[0]);
    // セパレータ があって 兼 2組
    branchs = parser.parse('社長室 兼 企画室', previous);
    System.assertEquals(1, branchs.size());
    System.assertEquals('社長室 兼 企画室', branchs[0]);
    // セパレータ があって 兼 3組
    branchs = parser.parse('社長室 兼 企画室 兼 IR室', previous);
    System.assertEquals(1, branchs.size());
    System.assertEquals('社長室 兼 企画室 兼 IR室', branchs[0]);
    // セパレータなく 兼 これは分かれちゃう → 兼 を特別扱いで、分かれない。
    branchs = parser.parse('社長室 兼企画室 兼IR室', previous);
    System.assertEquals(1, branchs.size());
    System.assertEquals('社長室 兼企画室 兼IR室', branchs[0]);
    // System.assertEquals(3, branchs.size());
    // System.assertEquals('社長室', branchs[0]);
    // System.assertEquals('兼企画室', branchs[1]);
    // System.assertEquals('兼IR室', branchs[2]);
    // 兼fogefoge だと へんになるけど、
    branchs = parser.parse('大事業部 営業部 兼平営業所', previous);
    System.assertEquals(2, branchs.size());
    System.assertEquals('大事業部', branchs[0]);
    System.assertEquals('営業部 兼平営業所', branchs[1]);
  }

  // Separater タイプ: 英語のみなら Comparision タイプを使うのと同じ結果
  @isTest
  static void test_SeparaterParser_English() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Separator);
    List<String> branchs;
    branchs = parser.parse('Productivity and Business Processes Sales Group', new List<String> { 'Productivity and Business Processes' });
    System.assertEquals(2, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);
    System.assertEquals('Sales Group', branchs[1]);
  }

  @isTest
  static void test_LineParser() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Line);
    List<String> branchs;

    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部', null);
    System.assertEquals(3, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);

    // 改行がなくても 前のと比較して 階層抽出
    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部 ビジネス推進課', branchs);
    System.assertEquals(4, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);
    System.assertEquals('ビジネス推進課', branchs[3]);

    // 改行がなくても 前のと比較して 階層抽出
    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部 別のビジネス推進課', branchs);
    System.assertEquals(4, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);
    System.assertEquals('別のビジネス推進課', branchs[3]);

    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部\n別のビジネス推進課 その係', branchs);
    System.assertEquals(5, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);
    System.assertEquals('別のビジネス推進課', branchs[3]);
    System.assertEquals('その係', branchs[4]);
  }

  @isTest
  static void test_ComparisionParser() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Comparision);
    List<String> branchs;

    branchs = parser.parse('大きな会社組織 プロファクト事業部', null);
    System.assertEquals(1, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 営業部', branchs);
    System.assertEquals(2, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 営業部 Sales & Marketing グループ', branchs);
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);
    System.assertEquals('Sales & Marketing グループ', branchs[2]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 開発部 開発 と 試験 グループ', branchs);
    System.assertEquals(2, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('開発部 開発 と 試験 グループ', branchs[1]);
  }

  @isTest
  static void test_ComparisionParser_lines() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Comparision);
    List<String> branchs;

    branchs = parser.parse('大きな会社組織 プロファクト事業部', null);
    System.assertEquals(1, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部\n営業部', branchs);
    System.assertEquals(2, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 営業部\nSales & Marketing グループ', branchs);
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);
    System.assertEquals('Sales & Marketing グループ', branchs[2]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 開発部\n開発 と 試験 グループ', branchs);
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('開発部', branchs[1]);
    System.assertEquals('開発 と 試験 グループ', branchs[2]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 開発部 開発 と 試験 グループ', branchs); // 改行でなくても、前のと一致を判断する
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('開発部', branchs[1]);
    System.assertEquals('開発 と 試験 グループ', branchs[2]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 開発部開発 と 試験 グループ', branchs); // 詰まってても、前のと一致を判断する
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('開発部', branchs[1]);
    System.assertEquals('開発 と 試験 グループ', branchs[2]);

    branchs = parser.parse('大きな会社組織 プロファクト事業部 開発部テスト グループ', branchs); // 詰まってても、前のと一致を判断する
    System.assertEquals(3, branchs.size());
    System.assertEquals('大きな会社組織 プロファクト事業部', branchs[0]);
    System.assertEquals('開発部', branchs[1]);
    System.assertEquals('テスト グループ', branchs[2]);
  }

  @isTest
  static void test_ComparisionParser_English() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Comparision);
    List<String> branchs;

    branchs = parser.parse('Productivity and Business Processes',
              new List<String> { 'Tokyo Factory' });
    System.assertEquals(1, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);

    branchs = parser.parse('Productivity and Business Processes Dev Group',
              new List<String> { 'Productivity and Business Processes' });
    System.assertEquals(2, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);
    System.assertEquals('Dev Group', branchs[1]);

    branchs = parser.parse('Productivity and Business Processes Sales Group',
              new List<String> { 'Productivity and Business Processes', 'Dev Group' });
    System.assertEquals(2, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);
    System.assertEquals('Sales Group', branchs[1]);

    branchs = parser.parse('Productivity and Business Processes Sales Group Large Corp.',
              new List<String> { 'Productivity and Business Processes', 'Sales Group' });
    System.assertEquals(3, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);
    System.assertEquals('Sales Group', branchs[1]);
    System.assertEquals('Large Corp.', branchs[2]);

    branchs = parser.parse('Productivity and Business Processes Sales Group Small Corp.',
              new List<String> { 'Productivity and Business Processes', 'Sales Group', 'Large Corp.' });
    System.assertEquals(3, branchs.size());
    System.assertEquals('Productivity and Business Processes', branchs[0]);
    System.assertEquals('Sales Group', branchs[1]);
    System.assertEquals('Small Corp.', branchs[2]);
  }

  @isTest
  static void test_RegexParser() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Regex);
    List<String> branchs;
    branchs = parser.parse('〇〇事業部営業部第1課', new List<String> { '△△事業部', '営業部', '第1課' });
    System.assertEquals(3, branchs.size());
    System.assertEquals('〇〇事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);
    System.assertEquals('第1課', branchs[2]);
  }

  // 正規表現 部署項目は複数行
  @isTest
  static void test_RegexParser_Lines() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Regex);
    List<String> branchs;

    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部', null);
    System.assertEquals(3, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);

    branchs = parser.parse('ビジネス事業本部\nビジネス事業部\nビジネス推進部\n', null);
    System.assertEquals(3, branchs.size());
    System.assertEquals('ビジネス事業本部', branchs[0]);
    System.assertEquals('ビジネス事業部', branchs[1]);
    System.assertEquals('ビジネス推進部', branchs[2]);

  }

  @isTest
  static void test_RegexParser_English() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Regex);
    List<String> branchs;
    branchs = parser.parse('〇〇事業部 営業部 第1課', new List<String> { '△△事業部', '営業部', '第1課' });
    System.assertEquals(3, branchs.size());
    System.assertEquals('〇〇事業部', branchs[0]);
    System.assertEquals('営業部', branchs[1]);
    System.assertEquals('第1課', branchs[2]);

    branchs = parser.parse('Product Type Divisions, Productivity and Business Processes',
              new List<String> { '〇〇事業部', '営業部', '第1課' });
    System.assertEquals(1, branchs.size());
    System.assertEquals('Product Type Divisions, Productivity and Business Processes', branchs[0]);

    branchs = parser.parse('Product Type Divisions, Productivity and Business Processes Dev Group',
              new List<String> { 'Product Type Divisions, Productivity and Business Processes' });
    System.assertEquals(1, branchs.size());
    System.assertEquals('Product Type Divisions, Productivity and Business Processes Dev Group', branchs[0]);

    branchs = parser.parse('Product Type Divisions, Productivity and Business Processes Sales Group',
              new List<String> { 'Product Type Divisions, Productivity and Business Processes Dev Group' });
    System.assertEquals(1, branchs.size());
    System.assertEquals('Product Type Divisions, Productivity and Business Processes Sales Group', branchs[0]);

  }

  // SV_DEV-2474 【組織情報DX】：部署の「空白などの文字」で分割されない場合がある
  // こういう仕様
  @isTest
  static void test_SeparaterParser_colon() {
    SB_Ot_DepartmentParser.DepartmentParser parser = SB_Ot_DepartmentParser.createParser(SB_Ot_OrgTreeConfig.DepartmentParser.Separator);
    List<String> branchs;
    //
    branchs = parser.parse('18: テキスト 18: テキスト 18: テキスト', new List<String> ());
    System.assertEquals(3, branchs.size());
  }
/**
MS
http://panmore.com/microsoft-corporation-organizational-structure-characteristics-analysis
Product Type Divisions.
Productivity and Business Processes
Intelligent Cloud
More Personal Computing
Corporate and Other

Global Corporate Groups.
Office of the CEO
Worldwide Commercial Business
Marketing
Microsoft Global Sales, Marketing and Operations
Corporate Strategy and Operations
Microsoft Cloud and Enterprise Group
Human Resources
Finance
Business Development
Applications and Services Group
Windows and Devices Group
Technology and Research
Legal
**/

}