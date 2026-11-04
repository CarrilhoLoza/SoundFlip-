. (Join-Path $PSScriptRoot 'Common.ps1')
try{Start-TrocaSom -Configure}catch{[void][Windows.Forms.MessageBox]::Show($_.Exception.Message,'TrocaSom')}
