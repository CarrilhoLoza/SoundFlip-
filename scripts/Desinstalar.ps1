. (Join-Path $PSScriptRoot 'Common.ps1')
try{
 if(!(Test-Path -LiteralPath $dest)){[void][Windows.Forms.MessageBox]::Show('O TrocaSom não está instalado.');exit}
 $r=[Windows.Forms.MessageBox]::Show('Remover o TrocaSom, as configurações, os ícones e a inicialização automática? O módulo AudioDeviceCmdlets será mantido para não afetar outros programas.','TrocaSom | Desinstalar','YesNo','Warning')
 if($r -ne 'Yes'){exit}
 Stop-TrocaSom
 $startup=Join-Path ([Environment]::GetFolderPath('Startup')) 'TrocaSom.lnk'
 if(Test-Path -LiteralPath $startup){Remove-Item -LiteralPath $startup -Force}
 $menu=Join-Path ([Environment]::GetFolderPath('Programs')) 'TrocaSom'
 if(Test-Path -LiteralPath $menu){Remove-Item -LiteralPath $menu -Recurse -Force}
 Remove-Item -LiteralPath $dest -Recurse -Force
 [void][Windows.Forms.MessageBox]::Show('TrocaSom removido com sucesso.','TrocaSom')
}catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'Falha na desinstalação');exit 1}
