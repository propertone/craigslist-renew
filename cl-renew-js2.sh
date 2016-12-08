#!/usr/bin/env node

; The data to be sent
$sPD = 'action=/manage/##########&name=action&value=renew&name=crypt&value=U2FsdGVkX182MzM0NjMzNOpDZW1SVeBDug_VuldCvGPgwoMzcrXJZA'


; Creating the object
$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP.Open("POST", "https://post.craigslist.org", False)
$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

; Performing the Request
$oHTTP.Send($sPD)

; Download the body response if any, and get the server status response code.
$oReceived = $oHTTP.ResponseText
$oStatusCode = $oHTTP.Status

;If $oStatusCode <> 200 then
 MsgBox(4096, "Response code", $oStatusCode)
;EndIf

; Saves the body response regardless of the Response code
 $file = FileOpen("Received.html", 2) ; The value of 2 overwrites the file if it already exists
 FileWrite($file, $oReceived)
 FileClose($file)
