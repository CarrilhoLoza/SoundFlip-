$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
$dest=Join-Path $env:LOCALAPPDATA 'TrocaSom'
$exe=Join-Path $PSHOME 'powershell.exe'
function Start-TrocaSom([switch]$Configure){
 $app=Join-Path $dest 'scripts\TrocaSom.ps1'
 if(!(Test-Path -LiteralPath $app)){throw 'TrocaSom não está instalado. Execute Instalar.bat primeiro.'}
 $args='-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$app+'"'
 if($Configure){$args+=' -Configure'}
 Start-Process -FilePath $exe -ArgumentList $args -WindowStyle Hidden
}
function Stop-TrocaSom{
 if(!(Test-Path -LiteralPath $dest)){return}
 $m=New-Object Threading.Mutex($false,'Local\TrocaSomComplete4')
 try{
  $free=$m.WaitOne(0)
  if($free){$m.ReleaseMutex();return}
  [IO.File]::WriteAllText((Join-Path $dest 'stop.request'),'1')
  for($i=0;$i -lt 100;$i++){
   Start-Sleep -Milliseconds 150
   if($m.WaitOne(0)){$m.ReleaseMutex();return}
  }
  throw 'Feche a janela de configurações e escolha Sair no ícone do TrocaSom. Depois tente novamente.'
 }finally{$m.Dispose()}
}
function New-AppShortcut([string]$path,[string]$arguments){
 $shell=New-Object -ComObject WScript.Shell;$s=$shell.CreateShortcut($path)
 $s.TargetPath=$exe;$s.Arguments=$arguments;$s.WorkingDirectory=$dest
 $s.IconLocation=(Join-Path $dest 'assets\TrocaSom.ico')+',0';$s.WindowStyle=7;$s.Save()
}
