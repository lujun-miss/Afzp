
# 批量修改HTML文件，将"安全防控"移动到导航菜单最后位置

$htmlFiles = Get-ChildItem -Path "d:\工具\Trae\Afzp" -Recurse -Filter "*.html" | Where-Object {
    $_.FullName -notlike "*\node_modules\*" -and $_.FullName -notlike "*\dist\*" -and $_.FullName -notlike "*\.vite\*"
}

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    
    # 检查文件是否包含"安全防控"导航链接
    if ($content -match '安全防控') {
        Write-Host "处理文件: $($file.FullName)"
        
        # 定义导航菜单模式
        $navPattern = '<div class="hidden md:flex items-center gap-4">([\s\S]*?)</div>'
        
        # 查找导航菜单
        if ($content -match $navPattern) {
            $navMenu = $matches[1]
            
            # 提取所有导航链接
            $links = [regex]::Matches($navMenu, '<a[^>]+>[^<]+</a>') | ForEach-Object { $_.Value }
            
            # 分离"安全防控"链接和其他链接
            $securityLink = $links | Where-Object { $_ -match '安全防控' }
            $otherLinks = $links | Where-Object { $_ -notmatch '安全防控' }
            
            if ($securityLink) {
                # 构建新的导航菜单内容
                $newNavMenu = ($otherLinks + $securityLink) -join "`n"
                
                # 替换原导航菜单
                $newContent = $content -replace $navPattern, "<div class=`"hidden md:flex items-center gap-4`">`n$newNavMenu`n</div>"
                
                # 保存修改后的内容
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
                
                Write-Host "已更新: $($file.FullName)"
            }
        }
    }
}

Write-Host "处理完成!"
