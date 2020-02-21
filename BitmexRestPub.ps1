
$InfluxDB = 'http://172.20.36.115:8086/write?db=telegraf'




#$Key = 'LAqUlXMUreyu3qn'
#$Secret = 'chNOOS4KvNXR_cLATCRlcBwyKDYnWgO'


#$expires = "1518064236"
$expires = (([int][double]::Parse((Get-Date -UFormat %s)) + 60 )).ToString()  # 10 minuten


$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

$baseUri = "https://www.bitmex.com"

$verb = "GET"
$path = "/api/v1/user"
$data = ""
$toencode = $verb + "" + $path + "" + $expires + "" + $data
$signature = (($hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($toencode)) | ForEach-Object ToString X2) -join '')

$Uri = $baseUri + $path

$Headers = @{
'Accept' = 'application/json'
'api-expires' = $expires
'api-key' = $key
'api-signature' = $signature
}

$UserInfo = Invoke-RestMethod -Uri "https://www.bitmex.com/api/v1/user" -Method GET -Headers $Headers  





$verb = "GET"
$path = "/api/v1/position"
$data = ""

$toencode = $verb + "" + $path + "" + $expires + "" + $data
$signature = (($hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($toencode)) | ForEach-Object ToString X2) -join '')

$Uri = $baseUri + $path

$Headers = @{
'Accept' = 'application/json'
'api-expires' = $expires
'api-key' = $key
'api-signature' = $signature
}

$Positions = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers  





$verb = "GET"
$path = "/api/v1/user/wallet"
$data = ""

$toencode = $verb + "" + $path + "" + $expires + "" + $data
$signature = (($hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($toencode)) | ForEach-Object ToString X2) -join '')

$Uri = $baseUri + $path

$Headers = @{
'Accept' = 'application/json'
'api-expires' = $expires
'api-key' = $key
'api-signature' = $signature
}

$Wallet = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers  



$PositionXBT = $Positions | Where-Object {$_.symbol -eq "XBTUSD"}

$walletamount = $Wallet.amount / 100000000
$unrealisedpnl = $PositionXBT.unrealisedPnl  / 100000000
$balance = $walletamount + $unrealisedpnl

$lastprice = $PositionXBT.lastPrice


#data naar influxdb schrijven

$body = "Bitmex,Symbol=XBT Wallet=$walletamount,UnrealisedPNL=$unrealisedpnl,Balance=$balance,LastPrice=$lastprice" 
Write-Output $Body

Invoke-RestMethod -Uri $InfluxDB -Method POST -Body $body 









