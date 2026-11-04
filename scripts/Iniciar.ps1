. (Join-Path $PSScriptRoot 'Common.ps1')
try{Start-TrocaSom}catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'TrocaSom')}
