param([switch]$Configure)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$root=Split-Path $PSScriptRoot
$config=Join-Path $root 'config.json'
$mutex=New-Object Threading.Mutex($false,'Local\TrocaSomComplete4')
$owned=$mutex.WaitOne(0)
if(!$owned){
 if($Configure){[IO.File]::WriteAllText((Join-Path $root 'configure.request'),'1')}
 $mutex.Dispose();exit
}
$tray=$null;$hot=$null;$icon=$null;$timer=$null
try {
Import-Module AudioDeviceCmdlets -ErrorAction Stop
Add-Type -ReferencedAssemblies System.Windows.Forms -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class SoundKeys : NativeWindow, IDisposable {
 [DllImport("user32.dll", SetLastError=true)] static extern bool RegisterHotKey(IntPtr h,int id,uint mods,uint key);
 [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr h,int id);
 public event Action Pressed;
 int active=0; uint mods, key;
 public SoundKeys(){CreateHandle(new CreateParams());}
 public bool Bind(uint m,uint k){
  if(active!=0 && m==mods && k==key)return true;
  int next=active==1?2:1;
  if(!RegisterHotKey(Handle,next,m|0x4000,k))return false;
  if(active!=0)UnregisterHotKey(Handle,active);
  active=next;mods=m;key=k;return true;
 }
 protected override void WndProc(ref Message msg){
  if(msg.Msg==0x0312 && msg.WParam.ToInt32()==active && Pressed!=null)Pressed();
  base.WndProc(ref msg);
 }
 public void Dispose(){if(Handle!=IntPtr.Zero){if(active!=0)UnregisterHotKey(Handle,active);DestroyHandle();}}
}
"@
$script:state=@{Ids=@();Modifiers=3;Key=83}
$script:busy=$false
$codes=@(65..90)+@(48..57)+@(112..122)
if(Test-Path -LiteralPath $config){
 try{
  $p=Get-Content -LiteralPath $config -Raw|ConvertFrom-Json
  if(@($p.Ids).Count -eq 2 -and [int]$p.Modifiers -ge 1 -and [int]$p.Modifiers -le 7 -and $codes -contains [int]$p.Key){
   $script:state=@{Ids=@($p.Ids);Modifiers=[int]$p.Modifiers;Key=[int]$p.Key}
  }
 }catch{}
}
$icon=New-Object Drawing.Icon((Join-Path $root 'assets\TrocaSom.ico'))
$hot=New-Object SoundKeys
$script:bound=$hot.Bind([uint32]$script:state.Modifiers,[uint32]$script:state.Key)
$tray=New-Object Windows.Forms.NotifyIcon
$tray.Icon=$icon;$tray.Visible=$true
function Update-Tooltip{
 $parts=@();$m=$script:state.Modifiers
 if($m -band 2){$parts+='Ctrl'};if($m -band 1){$parts+='Alt'};if($m -band 4){$parts+='Shift'}
 $k=$script:state.Key
 if($k -ge 112){$parts+=('F'+($k-111))}else{$parts+=[string][char]$k}
 $tray.Text='TrocaSom - '+($parts -join '+')
}
function Show-Settings{
 if($script:busy){return};$script:busy=$true
 $f=$null
 try{
  $devices=@(Get-AudioDevice -List|Where-Object {$_.Type -eq 'Playback'})
  $f=New-Object Windows.Forms.Form
  $f.Text='TrocaSom | Configurações';$f.ClientSize=New-Object Drawing.Size(590,365)
  $f.StartPosition='CenterScreen';$f.FormBorderStyle='FixedDialog';$f.MaximizeBox=$false;$f.MinimizeBox=$false
  $f.BackColor=[Drawing.Color]::FromArgb(245,247,251);$f.Icon=$icon
  $f.Font=New-Object Drawing.Font('Segoe UI',10)
  $title=New-Object Windows.Forms.Label;$title.Text='Seu áudio, a um atalho de distância.'
  $title.SetBounds(22,16,545,30);$title.Font=New-Object Drawing.Font('Segoe UI',13,[Drawing.FontStyle]::Bold)
  $f.Controls.Add($title)
  $boxes=@()
  foreach($i in 0,1){
   $l=New-Object Windows.Forms.Label;$l.Text='Saída '+($i+1);$l.SetBounds(24,(59+66*$i),540,23);$f.Controls.Add($l)
   $c=New-Object Windows.Forms.ComboBox;$c.DropDownStyle='DropDownList';$c.SetBounds(24,(83+66*$i),540,28)
   foreach($d in $devices){[void]$c.Items.Add([string]$d.Name)}
   if($c.Items.Count -gt $i){$c.SelectedIndex=$i}
   if($script:state.Ids.Count -eq 2){for($j=0;$j -lt $devices.Count;$j++){if($devices[$j].ID -eq $script:state.Ids[$i]){$c.SelectedIndex=$j}}}
   $boxes+=$c;$f.Controls.Add($c)
  }
  $l=New-Object Windows.Forms.Label;$l.Text='Atalho para alternar';$l.SetBounds(24,192,540,24);$f.Controls.Add($l)
  $checks=@()
  $names=@('Ctrl','Alt','Shift');$masks=@(2,1,4)
  foreach($i in 0,1,2){
   $c=New-Object Windows.Forms.CheckBox;$c.Text=$names[$i];$c.SetBounds((24+$i*85),222,80,28)
   $c.Checked=($script:state.Modifiers -band $masks[$i]) -ne 0;$checks+=$c;$f.Controls.Add($c)
  }
  $keys=New-Object Windows.Forms.ComboBox;$keys.DropDownStyle='DropDownList';$keys.SetBounds(300,222,130,28)
  foreach($k in $codes){$name=if($k -ge 112){'F'+($k-111)}else{[string][char]$k};[void]$keys.Items.Add($name)}
  $keys.SelectedIndex=[Array]::IndexOf($codes,[int]$script:state.Key);$f.Controls.Add($keys)
  $hint=New-Object Windows.Forms.Label;$hint.Text='Escolha ao menos um modificador. Ex.: Ctrl + Alt + S.'
  $hint.SetBounds(24,263,540,27);$f.Controls.Add($hint)
  $save=New-Object Windows.Forms.Button;$save.Text='Salvar';$save.SetBounds(428,309,136,36)
  $save.BackColor=[Drawing.Color]::FromArgb(30,116,133);$save.ForeColor=[Drawing.Color]::White;$save.FlatStyle='Flat'
  $save.Add_Click({
   if($boxes[0].SelectedIndex -lt 0 -or $boxes[1].SelectedIndex -lt 0){[void][Windows.Forms.MessageBox]::Show('Conecte duas saídas de áudio.');return}
   $ids=@($devices[$boxes[0].SelectedIndex].ID,$devices[$boxes[1].SelectedIndex].ID)
   if($ids[0] -eq $ids[1]){[void][Windows.Forms.MessageBox]::Show('Escolha duas saídas diferentes.');return}
   $m=0;foreach($i in 0,1,2){if($checks[$i].Checked){$m=$m -bor $masks[$i]}}
   if(!$m -or $keys.SelectedIndex -lt 0){[void][Windows.Forms.MessageBox]::Show('Escolha um modificador e uma tecla.');return}
   $k=[int]$codes[$keys.SelectedIndex]
   if(!$hot.Bind([uint32]$m,[uint32]$k)){[void][Windows.Forms.MessageBox]::Show('Atalho indisponível. Escolha outra combinação. O anterior foi mantido.');return}
   try{
    $next=@{Ids=$ids;Modifiers=$m;Key=$k}
    $next|ConvertTo-Json|Set-Content -LiteralPath ($config+'.tmp') -Encoding UTF8
    Move-Item -LiteralPath ($config+'.tmp') -Destination $config -Force
    $script:state=$next;$script:bound=$true;Update-Tooltip;$f.Close()
   }catch{
    [void]$hot.Bind([uint32]$script:state.Modifiers,[uint32]$script:state.Key)
    [void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'Erro ao salvar')
   }
  })
  $f.Controls.Add($save)
  $refresh=New-Object Windows.Forms.Button;$refresh.Text='Atualizar saídas';$refresh.SetBounds(24,309,160,36)
  $refresh.Add_Click({$f.Tag='refresh';$f.Close()});$f.Controls.Add($refresh)
  [void]$f.ShowDialog();$again=$f.Tag -eq 'refresh'
 }catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'TrocaSom')}
 finally{if($f){$f.Dispose()};$script:busy=$false}
 if($again){Show-Settings}
}
$context=New-Object Windows.Forms.ApplicationContext
$menu=New-Object Windows.Forms.ContextMenuStrip
$item=$menu.Items.Add('Configurações');$item.Add_Click({Show-Settings})
$item=$menu.Items.Add('Sair');$item.Add_Click({$context.ExitThread()})
$tray.ContextMenuStrip=$menu;$tray.Add_DoubleClick({Show-Settings});Update-Tooltip
$hot.add_Pressed({
 if($script:busy){return}
 if($script:state.Ids.Count -ne 2){Show-Settings;return}
 $script:busy=$true
 try{
  $current=Get-AudioDevice -Playback
  $target=$script:state.Ids[0]
  if($current.ID -eq $target){$target=$script:state.Ids[1]}
  $device=@(Get-AudioDevice -List|Where-Object {$_.Type -eq 'Playback' -and $_.ID -eq $target})
  if(!$device.Count){throw 'Saída desconectada. Reconecte ou escolha outra nas configurações.'}
  Set-AudioDevice -ID $target|Out-Null
 }catch{$tray.BalloonTipTitle='TrocaSom';$tray.BalloonTipText=$_.Exception.Message;$tray.ShowBalloonTip(4000)}
 finally{$script:busy=$false}
})
$timer=New-Object Windows.Forms.Timer;$timer.Interval=600
$timer.Add_Tick({
 if(Test-Path -LiteralPath (Join-Path $root 'stop.request')){
  Remove-Item -LiteralPath (Join-Path $root 'stop.request') -Force -ErrorAction SilentlyContinue
  $context.ExitThread();return
 }
 if(!$script:busy -and (Test-Path -LiteralPath (Join-Path $root 'configure.request'))){
  Remove-Item -LiteralPath (Join-Path $root 'configure.request') -Force -ErrorAction SilentlyContinue
  Show-Settings
 }
});$timer.Start()
if($Configure -or $script:state.Ids.Count -ne 2 -or !$script:bound){Show-Settings}
[Windows.Forms.Application]::Run($context)
}catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'TrocaSom - erro')}
finally{
 if($timer){$timer.Stop();$timer.Dispose()}
 if($tray){$tray.Visible=$false;$tray.Dispose()}
 if($hot){$hot.Dispose()};if($icon){$icon.Dispose()}
 $mutex.ReleaseMutex();$mutex.Dispose()
}
