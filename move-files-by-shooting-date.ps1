# 処理対象のディレクトリを指定
$targetDir = "C:\Users\motoyuki\Desktop\emiko\DCIM\100SHARP"

# Shell.Application COMオブジェクトを作成
$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace($targetDir)

# 対象ディレクトリ内のJPEGファイルを取得
Get-ChildItem -Path $targetDir -Filter *.jpg -File | ForEach-Object {
    $file = $_
    $folderItem = $folder.ParseName($file.Name)

    # Exifの撮影日（DateTaken）を取得（プロパティID 12 は "Date taken"）
    $dateTakenStr = $folder.GetDetailsOf($folderItem, 12)

    if ([string]::IsNullOrWhiteSpace($dateTakenStr)) {
        Write-Warning "撮影日が取得できません: $($file.FullName)"
        return
    }
    $dateTakenStr = $dateTakenStr.ToString() -replace [char]0x200E, ""
    $dateTakenStr = $dateTakenStr.ToString() -replace [char]0x200F, ""
    $dateTakenStr = $dateTakenStr.Split(' ')[0]  # 日付部分のみ取得

    # 撮影日をDateTime型に変換
    try {
        $dateTaken = [datetime]::ParseExact($dateTakenStr, 'yyyy/MM/dd', $null)
    }
    catch {
        Write-Warning "撮影日が解析できません: $($file.FullName)"
        return
    }

    # yyyy-MM-dd形式のフォルダ名を作成
    $dateFolderName = $dateTaken.ToString("yyyy-MM-dd")
    $destFolder = Join-Path $targetDir $dateFolderName

    # フォルダが存在しなければ作成
    if (-not (Test-Path $destFolder)) {
        New-Item -Path $destFolder -ItemType Directory | Out-Null
    }

    # ファイルを移動
    Move-Item -Path $file.FullName -Destination $destFolder
    Write-Host "Moved: $($file.Name) -> $dateFolderName"
}
