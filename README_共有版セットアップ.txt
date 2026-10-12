マリポケ エリア管理（Supabase共有版・初期パッケージ）

このパッケージは、既存のKML変換・面積計算・重複判定・GeoJSON出力を残し、Supabaseのareasテーブルに登録/削除/読み込みを行う共有版の初期パッケージです。
まだ公開完了ではありません。以下の設定を行ってからGitHubへアップロードしてください。

ファイル
- index.html：共有版画面
- config.js：Supabase Project URL と公開用 anon/publishable key の設定
- setup_security.sql：2人のユーザーだけがエリアを操作できるようにするRLS設定

重要なセキュリティ注意
- config.jsにはSupabaseのProject URLと公開用anon/publishable keyのみを設定してください。
- service_role key、secret key、DBパスワードは絶対にフロントエンドへ入れないでください。
- このリポジトリをPublicにする場合、config.jsも公開されます。公開用キーはRLSと正しいポリシーが必須です。
- setup_security.sqlを実行するまでは、既存のSQLで「authenticatedユーザー全員」に許可がある可能性があります。公開前に必ず実行してください。
- このアプリはSupabase Authのメール/パスワードログインを使います。サインアップ画面はありません。管理者がSupabase Authentication > Usersでユーザーを作成します。

セットアップ手順（これから案内する順番）
1. Supabaseダッシュボード > Project Settings / API（画面によっては「Connect」やAPI Keys）でProject URLと公開用anon/publishable keyを確認する。
2. config.jsの2つの値を自分のプロジェクトの値に置き換える。
3. Supabase SQL Editorでsetup_security.sqlを実行する。
4. Authentication > Usersで各ユーザーのUIDを確認する。許可する2人のUIDをSQL Editorで以下のように登録する（実際のUUIDへ置き換える）。
   insert into public.area_access (user_id) values
   ('YOUR_FIRST_USER_UUID'),
   ('YOUR_SECOND_USER_UUID')
   on conflict (user_id) do nothing;
5. 2人分のユーザーを作成してから、GitHub Pages等でHTTPS公開する。
6. Supabase Authentication > URL ConfigurationのSite URLとRedirect URLsを公開先URLに合わせる。
7. 公開URLで両方のユーザーがログインし、GeoJSON登録・再読み込み・削除・KML判定をテストする。

データベース前提
- public.areasテーブルが存在し、カラムは id, name, geojson, area_km2, created_at, updated_at。
- 既に前段の案内で作成したテーブルに合わせています。
- 既存のローカル試作版データは自動移行されません。必要なら試作版からGeoJSONをバックアップし、共有版へ再登録してください。

現在の制限
- KMLのPolygon/MultiPolygonを中心に処理します。複雑なKMLやGeometryCollection等は未対応です。
- 重複判定はTurfによる近似計算です。複雑な形状で判定できない交差はスキップされることがあります。重要な登録では地図と数値を確認してください。
- 既存エリア数が多い場合はブラウザで全件取得するため、数千件規模では後からページングやサーバー側空間検索を導入するのが望ましいです。
- GeoJSONファイルを複数登録すると、ファイルごとにエリア1件として保存されます。
