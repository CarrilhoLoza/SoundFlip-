. (Join-Path $PSScriptRoot 'Common.ps1')
try{
 $r=[Windows.Forms.MessageBox]::Show('Instalar o TrocaSom para seu usuário e iniciar automaticamente ao entrar no Windows?','TrocaSom | Instalação','YesNo','Question')
 if($r -ne 'Yes'){exit}
 if(!(Get-Module -ListAvailable AudioDeviceCmdlets)){
  Write-Host 'Instalando dependência AudioDeviceCmdlets da PSGallery...'
  Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Repository PSGallery -ErrorAction Stop
 }
 Import-Module AudioDeviceCmdlets -ErrorAction Stop
 Stop-TrocaSom
 [void][IO.Directory]::CreateDirectory((Join-Path $dest 'scripts'))
 [void][IO.Directory]::CreateDirectory((Join-Path $dest 'assets'))
 $sourceRoot=Split-Path $PSScriptRoot
 foreach($f in @('TrocaSom.ps1','Common.ps1','Iniciar.ps1','Configurar.ps1','Desinstalar.ps1')){
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot $f) -Destination (Join-Path $dest ('scripts\'+$f)) -Force
 }
 Copy-Item -LiteralPath (Join-Path $sourceRoot 'assets\TrocaSom.ico') -Destination (Join-Path $dest 'assets\TrocaSom.ico') -Force
 foreach($flag in @('stop.request','configure.request')){Remove-Item -LiteralPath (Join-Path $dest $flag) -Force -ErrorAction SilentlyContinue}
 # Retira atalho da versao anterior; os dados so sao apagados pelo desinstalador.
 $startup=Join-Path ([Environment]::GetFolderPath('Startup')) 'TrocaSom.lnk'
 $appArgs='-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+(Join-Path $dest 'scripts\TrocaSom.ps1')+'"'
 New-AppShortcut $startup $appArgs
 $menu=Join-Path ([Environment]::GetFolderPath('Programs')) 'TrocaSom'
 [void][IO.Directory]::CreateDirectory($menu)
 New-AppShortcut (Join-Path $menu 'TrocaSom.lnk') $appArgs
 New-AppShortcut (Join-Path $menu 'Configurar TrocaSom.lnk') ($appArgs+' -Configure')
 $unArgs='-NoProfile -STA -ExecutionPolicy Bypass -File "'+(Join-Path $dest 'scripts\Desinstalar.ps1')+'"'
 New-AppShortcut (Join-Path $menu 'Desinstalar TrocaSom.lnk') $unArgs
 Start-TrocaSom -Configure
 [void][Windows.Forms.MessageBox]::Show('Instalação concluída! Configure as saídas e o atalho. O TrocaSom também está no menu Iniciar.','TrocaSom')
}catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'Falha na instalação');exit 1}
