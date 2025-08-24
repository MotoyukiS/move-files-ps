# 処理対象のルートディレクトリを指定
$rootPath = "C:\Users\motoyuki\Desktop\photo\test"

# 日付範囲を設定
$startDate = Get-Date "2025-11-27"
$endDate = Get-Date "2025-11-28"

# ルート直下のディレクトリを走査
Get-ChildItem -Path $rootPath -Directory | ForEach-Object {
    # ディレクトリ名が yyyy-MM-dd 形式か確認
    if ($_.Name -match '^\d{4}-\d{2}-\d{2}$') {
        try {
            $dirDate = Get-Date $_.Name -ErrorAction Stop
        }
        catch {
            return  # 日付変換できなければスキップ
        }

        # 日付範囲内か判定
        if ($dirDate -ge $startDate -and $dirDate -le $endDate) {
            $oppoPath = Join-Path $_.FullName "OPPO"

            # OPPOディレクトリを作成（存在しない場合）
            if (-not (Test-Path $oppoPath)) {
                New-Item -Path $oppoPath -ItemType Directory | Out-Null
            }

            # 日付ディレクトリ直下のファイルを取得（サブフォルダは除外）
            Get-ChildItem -Path $_.FullName -File | ForEach-Object {
                Move-Item -Path $_.FullName -Destination $oppoPath
            }
        }
    }
}
